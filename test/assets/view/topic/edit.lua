<%- partial('../editor_sidebar') %>

<div id='content'>
  <div class='panel'>
    <div class='header'>
      <ol class='breadcrumb'>
        <li><a href='/'>主页</a><span class='divider'>/</span></li>
        <% if action == 'edit' then %>
        <li class='active'>编辑话题</li>
        <% else %>
        <li class='active'>发布话题</li>
        <% end %>
      </ol>
    </div>

    <div class='inner post'>
      <% if edit_error then %>
      <div class="alert alert-error">
        <a class="close" data-dismiss="alert" href="#">&times;</a>
        <strong><%- edit_error %></strong>
      </div>
      <% end %>

      <% if the_error then %>
      <div class="alert alert-error">
        <strong><%- the_error %></strong>
      </div>
      <% else %>
          <% if action == 'edit' then %>
          <form id='create_topic_form' action='/topic/<%- topic_id %>/edit?_csrf=<%- csrf %>' method='post'>
          <% else %>
          <form id='create_topic_form' action='/topic/create?_csrf=<%- csrf %>' method='post'>
          <% end %>
          <fieldset>
            <span class="tab-selector">选择版块：</span>
            <select name="tab" id="tab-value">
              <option value="">请选择</option>
              <% local tabValue = tab or ''
              for _,pair in pairs(tabs) do
                local value = pair[1]
                local text = pair[2] %>
                <option value="<%- value %>" <%- tabValue == value and 'selected' or '' %>><%- text %></option>
              <% end %>
            </select>
            <span id="topic_create_warn"></span>
            <textarea autofocus class='span9' id='title' name='title' rows='1' placeholder="标题字数 10 字以上"><%- title or '' %></textarea>

            <div class='markdown_editor in_editor'>
              <div class='markdown_in_editor'>
                <textarea class='editor' name='t_content' rows='20' placeholder='文章支持 Markdown 语法, 请注意标记代码'><%- content or '' %></textarea>
                <div class='editor_buttons'>
                  <input type="submit" class='span-primary submit_btn' data-loading-text="提交中" value="提交">
                </div>
              </div>
            </div>
            <input type='hidden' id='topic_tags' name='topic_tags' value=''>
            <input type='hidden' name='_csrf' value='<%- csrf %>'>
          </fieldset>
        </form>
    </div>
    <% end %>
  </div>
</div>

<!-- markdown editor -->
<%- partial('../includes/editor') %>
<script>
  (function () {
    var editor = new Editor();
    editor.render($('.editor')[0]);

    // 版块选择的检查，必须选择
    $('#create_topic_form').on('submit', function (e) {
      var tabValue = $('#tab-value').val();
      if (!tabValue) {
        alert('必须选择一个版块！');
        $('.submit_btn').button('reset');
        $('.tab-selector').css('color', 'red');
        return false;
      }
    });
    // END 版块选择的检查，必须选择

    // 选择招聘版块时，给出提示
    $('#tab-value').on('change', function () {
      var $this = $(this);
      var value = $this.val();
      var warnMsg = '';
      if (value === 'job') {
        warnMsg = '<strong>为避免被管理员删帖，发帖时请好好阅读<a href="http://cnodejs.org/topic/541ed2d05e28155f24676a12" target="_blank">《招聘帖规范》</a></strong>';
      } else if (value === 'ask') {
        warnMsg = '<strong>提问时，请遵循 <a href="https://gist.github.com/alsotang/f654af8b1fff220e63fcb44846423e6d" target="_blank">《提问的智慧》</a>中提及的要点，以便您更接收到高质量回复。</strong>'
      }
      $('#topic_create_warn').html(warnMsg);
    });
    // END 选择招聘版块时，给出提示
  })();
</script>
