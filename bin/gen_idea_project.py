import argparse
import os
import subprocess
import typing
import re
import yaml
from urllib.parse import urlparse

import gitlab
from giturlparse import parse as git_urlparse


TPL_PYTHON = """
<?xml version="1.0" encoding="UTF-8"?>
<module type="WEB_MODULE" version="4">
  <component name="FacetManager">
    <facet type="Python" name="Python">
    </facet>
  </component>
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$USER_HOME$/{content_url}" />
    <orderEntry type="inheritedJdk" />
    <orderEntry type="sourceFolder" forTests="false" />
  </component>
</module>
"""

TPL_MODULE = """
<module fileurl="file://$PROJECT_DIR$/{iml_path}" filepath="$PROJECT_DIR$/{iml_path}" />
"""

MODULES_XML_TPL = """
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
    <component name="ProjectModuleManager">
        <modules>
            {modules}
        </modules>
    </component>
</project>
"""

TLP_VCS = """
<mapping directory="$PROJECT_DIR$/{project_path}" vcs="{vcs_type}" />
"""

VCS_XML_TPL = """
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="IssueNavigationConfiguration">
    <option name="links">
      <list>
        <IssueNavigationLink>
          <option name="issueRegexp" value="[A-Z]+\-\d+" />
          <option name="linkRegexp" value="https://jira.iponweb.net/browse/$0" />
        </IssueNavigationLink>
      </list>
    </option>
  </component>
  <component name="VcsDirectoryMappings">
    {modules}
  </component>
</project>
"""

HOME = os.path.expanduser('~')


def cmd_run(cmd, cwd=None):
    print(f'+ {cmd}')
    p = subprocess.Popen(
        cmd, shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        cwd=cwd)
    r = p.communicate()[0].decode().strip()
    print(r)
    if p.returncode != 0:
        raise RuntimeError
    return r


class EnvDefault(argparse.Action):
    def __init__(self, envvar, required=True, default=None, **kwargs):
        if not default and envvar:
            if envvar in os.environ:
                default = os.environ[envvar]
        if required and default:
            required = False
        super(EnvDefault, self).__init__(default=default, required=required,
                                         **kwargs)

    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, values)


class BaseProject:
    vcs_type = None

    def clone(self, sources_root):
        raise NotImplementedError

    def write_iml(self, idea_project_path, sources_root):
        path = self.iml_path(idea_project_path)

        if os.path.exists(path):
            print(f'{path} already exists')
        else:
            with open(path, 'w') as f:
                f.write(self.iml_body(sources_root))

    @property
    def name(self):
        raise NotImplementedError()

    def directory(self, sources_root):
        raise NotImplementedError()

    def iml_body(self, sources_root):
        return TPL_PYTHON.format(content_url=os.path.relpath(self.directory(sources_root), HOME)).strip()

    def iml_path(self, idea_project_path):
        return os.path.join(os.path.expanduser(idea_project_path), '.idea', f'{self.name}.iml')

    def module(self, idea_project_path):
        return TPL_MODULE \
            .format(iml_path=os.path.relpath(self.iml_path(idea_project_path), os.path.expanduser(idea_project_path))) \
            .strip()

    def vcs(self, idea_project_path, sources_root):
        if self.vcs_type is None:
            return None

        return TLP_VCS \
            .format(project_path=os.path.relpath(self.directory(sources_root), os.path.expanduser(idea_project_path)),
                    vcs_type=self.vcs_type) \
            .strip()


class GitProject(BaseProject):
    vcs_type = 'Git'

    def __init__(self, url, *, git_ff=False, git_upstream=None):
        self.url = url
        self.git_ff = git_ff
        self.git_upstream = git_upstream

    @property
    def name(self):
        parsed = git_urlparse(self.url)

        name_elements = []
        if parsed.owner:
            name_elements.append(parsed.owner)
        if parsed.groups:
            name_elements += parsed.groups
        name_elements.append(parsed.repo)

        return '.'.join(name_elements)

    def directory(self, sources_root):
        parsed = git_urlparse(self.url)

        directory_elements = []
        if parsed.owner:
            directory_elements.append(parsed.owner)
        if parsed.groups:
            directory_elements += parsed.groups
        directory_elements.append(parsed.repo)
        directory = os.path.join(*directory_elements)

        return os.path.join(sources_root, parsed.host, directory)

    def clone(self, sources_root):
        directory = self.directory(sources_root)

        if os.path.exists(os.path.join(directory, '.git')):
            current_origin = cmd_run(
                'git remote get-url origin', cwd=directory)

            if current_origin != self.url:
                print(directory)
                print(current_origin)
                print(self.url)
                raise ValueError(
                    'Directory already exists and uses another project')
        else:
            os.makedirs(directory)
            cmd_run(f'git clone "{self.url}" "{directory}"')

        if self.git_ff:
            cmd_run('git config pull.ff only', cwd=directory)

        if self.git_upstream:
            remotes = cmd_run('git remote show', cwd=directory).split('\n')
            if 'upstream' not in remotes:
                cmd_run(f'git remote add upstream {self.git_upstream}',
                        cwd=directory)


class HgProject(BaseProject):
    vcs_type = 'Mercurial'

    def __init__(self, url):
        self.url = url

    @property
    def name(self):
        parsed = urlparse(self.url)
        return '.'.join(parsed.path.strip('/').split('/'))

    def directory(self, sources_root):
        parsed = urlparse(self.url)
        directory = parsed.path.lstrip('/')
        return os.path.join(sources_root, parsed.hostname, directory)

    def clone(self, sources_root):
        directory = self.directory(sources_root)

        if os.path.exists(os.path.join(directory, '.hg')):
            pass
        else:
            os.makedirs(directory)
            cmd_run(f'hg clone "{self.url}" "{directory}"')


class LocalDirectoryProject(BaseProject):
    def __init__(self, url):
        self.url = url

    @property
    def name(self):
        return os.path.basename(self.url)

    def directory(self, sources_root):
        return os.path.expanduser(self.url)

    def clone(self, sources_root):
        pass


def discover_gitlab(config, token):
    include = config.get('include', [])
    exclude = config.get('exclude', [])

    if not token:
        raise ValueError('Gitlab API Token is not defined')

    gl = gitlab.Gitlab(f'https://{config["host"]}', token)

    result = []

    for project_raw in gl.projects.list(all=True):
        if project_raw.archived:
            continue

        path = project_raw.path_with_namespace

        if exclude:
            excluded = False
            for pattern in exclude:
                if re.match(pattern, path):
                    excluded = True
                    break
            if excluded:
                continue

        if include:
            included = False
            for pattern in include:
                if re.match(pattern, path):
                    included = True
                    break
            if not included:
                continue

        upstream = None
        if hasattr(project_raw, 'forked_from_project'):
            upstream = project_raw.forked_from_project['ssh_url_to_repo']

        project = GitProject(
            url=project_raw.ssh_url_to_repo,
            git_ff=project_raw.merge_method == 'ff',
            git_upstream=upstream,
        )

        result.append(project)

    return result


def main():
    parser = argparse.ArgumentParser(
        description='Generate idea project',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '-c', '--config', dest='config', action='store', required=True,
        help='project config path')
    parser.add_argument(
        '-t', '--gitlab-token', dest='gitlab_token', action=EnvDefault,
        envvar='CIP_GITLAB_TOKEN', help='gitlab token')
    parser.add_argument(
        '-i', '--idea-project-path', dest='idea_project_path', action='store',
        required=True,
        help='idea project path')
    parser.add_argument(
        '-s', '--sources-root', dest='sources_root', action='store',
        default=os.path.expanduser('~/dev'),
        help='directory to clones scm repositories to')
    parser.add_argument(
        '-d', '--debug', dest='debug', action='store_true',
        default=False,
        help='print debug logs')
    args = parser.parse_args()

    with open(os.path.expanduser(args.config), 'r') as config_file:
        config = yaml.load(config_file, yaml.FullLoader)

    projects: typing.List[BaseProject] = []

    for gitlab_discovery_config in config.get('gitlabDiscovery', []):
        projects += discover_gitlab(gitlab_discovery_config, args.gitlab_token)

    for project in config['repositories']:
        if url := project.get('git'):
            project = GitProject(
                url,
                git_ff=project.get('gitFastForward', False),
                git_upstream=project.get('gitUpstream', None),
            )
        elif url := project.get('hg'):
            project = HgProject(url)
        elif url := project.get('directory'):
            project = LocalDirectoryProject(url)
        else:
            raise ValueError('Unknown project type')

        projects.append(project)

    modules_to_add = []
    vcs_to_add = []
    for project in projects:
        project.clone(args.sources_root)
        project.write_iml(args.idea_project_path, args.sources_root)
        modules_to_add.append(project.module(args.idea_project_path))

        vcs = project.vcs(args.idea_project_path, args.sources_root)
        if vcs:
            vcs_to_add.append(vcs)

    modules_xml = MODULES_XML_TPL.format(modules='\n'.join(modules_to_add)).strip()
    if args.debug:
        print(f'XML:\n{modules_xml}')

    modules_file_path = os.path.join(
        os.path.expanduser(args.idea_project_path), '.idea', 'modules.xml')
    if os.path.exists(modules_file_path):
        with open(modules_file_path, 'w') as modules_file:
            modules_file.write(modules_xml)
    else:
        raise ValueError("Create an empty idea project first")

    vcs_xml = VCS_XML_TPL.format(modules='\n'.join(vcs_to_add)).strip()
    if args.debug:
        print(f'XML:\n{vcs_xml}')

    vcs_file_path = os.path.join(
        os.path.expanduser(args.idea_project_path), '.idea', 'vcs.xml')
    with open(vcs_file_path, 'w') as modules_file:
        modules_file.write(vcs_xml)


if __name__ == '__main__':
    main()
