<%- partial('../sign/sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ul class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <li class='active'>重置密码</li>
      </ul>
    </div>
    <div class='inner'>
      <% if the_error then %>
      <div class="alert alert-error">
        <a class="close" data-dismiss="alert" href="#">&times;</a>
        <strong><%- the_error %></strong>
      </div>
      <% end %>
      <form id='signin_form' class='form-horizontal' action='/reset_pass?_csrf=<%- csrf %>' method='post'>
        <div class='control-group'>
          <label class='control-label' for='psw'>新密码</label>
          <div class='controls'>
            <input class='input-xlarge' id='psw' name='psw' size='30' type='password'/>
          </div>
        </div>

        <div class='control-group'>
          <label class='control-label' for='repsw'>确认密码</label>
          <div class='controls'>
            <input class='input-xlarge' id='repsw' name='repsw' size='30' type='password'/>
          </div>
        </div>
        <input type='hidden' name='_csrf' value='<%- csrf %>'/>
        <input type='hidden' name='name' id='name' value='<%- name %>'>
        <input type='hidden' name='key' id='key' value='<%- key %>'>

        <div class='form-actions'>
          <input type='submit' class='span-primary' value='确定'/>
        </div>
      </form>
    </div>
  </div>
</div>