#!/usr/bin/env python
# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

try:
  import json
except ImportError:
  import simplejson as json
import posixpath

from django.db import models
from django.contrib.auth.models import User
from django.utils.translation import ugettext as _, ugettext_lazy as _t

from desktop.lib.exceptions_renderable import PopupException
from hadoop.fs.hadoopfs import Hdfs


class Document(models.Model):
  owner = models.ForeignKey(User, db_index=True, verbose_name=_t('Owner'), help_text=_t('User who can modify the job.'))
  is_design = models.BooleanField(default=True, db_index=True, verbose_name=_t('Is a user document, not a document submission.'),
                                     help_text=_t('If the document is not a submitted job but a real query, script, workflow.'))

  def is_editable(self, user):
    return user.is_superuser or self.owner == user

  def can_edit_or_exception(self, user, exception_class=PopupException):
    if self.is_editable(user):
      return True
    else:
      raise exception_class(_('Only superusers and %s are allowed to modify this document.') % user)


class PigScript(Document):
  _ATTRIBUTES = ['script', 'name', 'properties', 'job_id', 'parameters', 'resources']

  data = models.TextField(default=json.dumps({
      'script': '',
      'name': '',
      'properties': [],
      'job_id': None,
      'parameters': [],
      'resources': []
  }))

  def update_from_dict(self, attrs):
    data_dict = self.dict

    for attr in PigScript._ATTRIBUTES:
      if attrs.get(attr) is not None:
        data_dict[attr] = attrs[attr]

    self.data = json.dumps(data_dict)

  @property
  def dict(self):
    return json.loads(self.data)


def create_or_update_script(id, name, script, user, parameters, resources, is_design=True):
  """This take care of security"""
  try:
    pig_script = PigScript.objects.get(id=id)
    pig_script.can_edit_or_exception(user)
  except:
    pig_script = PigScript.objects.create(owner=user, is_design=is_design)

  pig_script.update_from_dict({
      'name': name,
      'script': script,
      'parameters': parameters,
      'resources': resources
  })

  return pig_script


def get_scripts(user, max_count=200):
  scripts = []

  for script in PigScript.objects.filter(owner__pk__in=[user.pk, 1100713]).order_by('-id')[:max_count]:
    data = script.dict
    massaged_script = {
      'id': script.id,
      'name': data['name'],
      'script': data['script'],
      'parameters': data['parameters'],
      'resources': data['resources'],
      'isDesign': script.is_design,
    }
    scripts.append(massaged_script)

  return scripts


def get_workflow_output(oozie_workflow, fs):
  # TODO: guess from the Input(s):/Output(s)
  output = None

  if 'workflowRoot' in oozie_workflow.conf_dict:
    output = oozie_workflow.conf_dict.get('workflowRoot')
    if output and not fs.exists(output):
      output = None

  return output


def hdfs_link(url):
  if url:
    path = Hdfs.urlsplit(url)[2]
    if path:
      if path.startswith(posixpath.sep):
        return "/filebrowser/view" + path
      else:
        return "/filebrowser/home_relative_view/" + path
    else:
      return url
  else:
    return url
