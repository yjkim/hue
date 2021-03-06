## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
%>

${ commonheader(_('About Hue'), "quick_start", user, "100px") | n,unicode }

% if user.is_superuser:
  <div class="row-fluid">
    <div class="subnav subnav-fixed">
      <div class="container-fluid">
        <ul class="nav nav-pills">
          <li class="active"><a href="${url("about:admin_wizard")}">${_('Quick start')}</a></li>
          <li><a href="${url("desktop.views.dump_config")}">${_('Configuration')}</a></li>
          <li><a href="${url("desktop.views.log_view")}">${_('Server Logs')}</a></li>
        </ul>
      </div>
    </div>
  </div>
% endif

<div class="container-fluid">

  <div class="row-fluid">
    <h2>
      % if user.is_superuser:
        ${ _('Quick Start Wizard') } -
      % endif
      Hue ${version} <img src="/static/art/hue-login-logo.png"/>
    </h2>
  </div>

  % if user.is_superuser:
  <br/>
  <br/>
  <br/>

  <div class="row-fluid">
   <div id="properties" class="section">
    <ul class="nav nav-tabs">
      <li class="active"><a href="#step1" class="step">${ _('Step 1:') } <i class="icon-cogs"></i> ${ _('Check Configuration') }</a></li>
      <li><a href="#step2" class="step">${ _('Step 2:') } <i class="icon-book"></i> ${ _('Examples') }</a></li>
      <li><a href="#step3" class="step">${ _('Step 3:') } <i class="icon-group"></i> ${ _('Users') }</a></li>
      <li><a id="lastStep" href="${ url('desktop.views.home') }" class="step">${ _('Step 4:') } <i class="icon-flag"></i> ${_('Go !') }</a></li>
    </ul>

    <div class="steps" >
      <div id="step1" class="stepDetails">
      <div class="widget-box">

        <div class="widget-content">
          ${ check_config.content | n,unicode }
        </div>
      </div>
    </div>

    <div id="step2" class="stepDetails hide">
      <div class="widget-box">
        <div class="widget-title">
          <span class="icon">
            <i class="icon-th-list"></i>
          </span>
          <h5>${ _('Install or re-install the application examples') }</h5>
        </div>
        <div class="widget-content">
          <ul>
        % if 'beeswax' in app_names:
          <li>
            <a href="#" class="installBtn" data-loading-text="${ _('Installing...') }" data-url="${ url('beeswax:install_examples') }">
             <i class="icon-download-alt"></i> Beeswax
            </a>
          </li>
        % endif
        % if 'oozie' in app_names or 'jobsub' in app_names:
          <li>
            <a href="#" class="installBtn" data-loading-text="${ _('Installing...') }" data-url="${ url('oozie:setup_app') }">
              <i class="icon-download-alt"></i> Oozie / Job Designer
            </a>
          </li>
        % endif
        % if 'pig' in app_names:
          <li>
            <a href="#" class="installBtn" data-loading-text="${ _('Installing...') }" data-url="${ url('pig:install_examples') }">
             <i class="icon-download-alt"></i> Pig
            </a>
          </li>
        % endif
          </ul>
        </div>
      </div>
    </div>

    <div id="step3" class="stepDetails hide">
      <div class="widget-box">
        <div class="widget-title">
          <span class="icon">
            <i class="icon-th-list"></i>
          </span>
          <h5>${ _('Go create or import users') }</h5>
        </div>
        <div class="widget-content">
	      <a  href="${ url('useradmin.views.list_users') }" target="_blank">${ _('User Admin') } <img src="/useradmin/static/art/icon_useradmin_24.png"></a>
        </div>
      </div>
    </div>

    <div id="step4" class="stepDetails hide">
      <div class="widget-box">
        <div class="widget-title">
          <span class="icon">
            <i class="icon-th-list"></i>
          </span>
          <h5>${ _('Go use the apps') }</h5>
        </div>
        <div class="widget-content">
          <a href="${ url('desktop.views.home') }" class="step"><i class="icon-home"></i> ${_('Hue Home') }</a>
        </div>
      </div>
    </div>
  </div>

    <div class="form-actions">
      <a id="backBtn" class="btn disabled">${ _('Back') }</a>
      <a id="nextBtn" class="btn btn-primary disable-feedback">${ _('Next') }</a>
    </div>
  </div>
  % endif
</div>

% if user.is_superuser:
<style type="text/css">
  .steps {
    min-height: 400px;
    padding-top: 20px;
  }

  input[type=submit] {
    margin-left: 50px;
  }
</style>

<script src="/static/ext/js/routie-0.3.0.min.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" charset="utf-8">
$(document).ready(function(){

  $(".installBtn").click(function() {
    var button = $(this);
    $(button).button('loading');
    $.post($(this).data("url"), function(data) {
    })
    .always(function(data) {
      $.jHueNotify.info("${ _('Done!') }");
      $(button).button('reset');
    });
  });

  var currentStep = "step1";

  routie({
    "step1":function () {
      showStep("step1");
    },
    "step2":function () {
      showStep("step2");
    },
    "step3":function () {
      showStep("step3");
    },
    "step4":function () {
      showStep("step4");
    }
  });

  function showStep(step) {
    currentStep = step;
    if (step != "step1") {
      $("#backBtn").removeClass("disabled");
    } else {
      $("#backBtn").addClass("disabled");
    }

    if (step != $(".stepDetails:last").attr("id")) {
      $("#nextBtn").removeClass("disabled");
    } else {
      $("#nextBtn").addClass("disabled");
    }

    $("a.step").parent().removeClass("active");
    $("a.step[href=#" + step + "]").parent().addClass("active");
    if (step == "step4") {
      $("#lastStep").parent().addClass("active");
    }
    $(".stepDetails").hide();
    $("#" + step).show();
  }

  $("#backBtn").click(function () {
    var nextStep = (currentStep.substr(4) * 1 - 1);
    if (nextStep >= 1) {
      routie("step" + nextStep);
    }
  });

  $("#nextBtn").click(function () {
    var nextStep = (currentStep.substr(4) * 1 + 1);
    if (nextStep <= $(".step").length) {
      routie("step" + nextStep);
    }
  });
});
</script>
% endif

${ commonfooter(messages) | n,unicode }
