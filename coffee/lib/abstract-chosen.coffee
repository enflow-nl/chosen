class AbstractChosen

  constructor: (@form_field, @options={}) ->
    return unless AbstractChosen.browser_is_supported()
    @is_multiple = @form_field.multiple
    this.set_default_text()
    this.set_default_values()

    this.setup()

    this.set_up_html()
    this.register_observers()
    # instantiation done, fire ready
    this.on_ready()

  set_default_values: ->
    @click_test_action = (evt) => this.test_active_click(evt)
    @activate_action = (evt) => this.activate_field(evt)
    @active_field = false
    @mouse_on_container = false
    @results_showing = false
    @result_highlighted = null
    @is_rtl = @options.rtl || /\bchosen-rtl\b/.test(@form_field.className)
    @allow_single_deselect = if @options.allow_single_deselect? and @form_field.options[0]? and @form_field.options[0].text is "" then @options.allow_single_deselect else false
    @disable_search_threshold = @options.disable_search_threshold || 0
    @disable_search = @options.disable_search || false
    @enable_split_word_search = if @options.enable_split_word_search? then @options.enable_split_word_search else true
    @group_search = if @options.group_search? then @options.group_search else true
    @search_contains = @options.search_contains || false
    @single_backstroke_delete = if @options.single_backstroke_delete? then @options.single_backstroke_delete else true
    @max_selected_options = @options.max_selected_options || Infinity
    @inherit_select_classes = @options.inherit_select_classes || false
    @display_selected_options = if @options.display_selected_options? then @options.display_selected_options else true
    @display_disabled_options = if @options.display_disabled_options? then @options.display_disabled_options else true

    # Detect mobile browser
    if /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(navigator.userAgent) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0,4)) || window.opera
      @is_touch = true
    else
      @is_touch = false

    @include_group_label_in_selected = @options.include_group_label_in_selected || false
    @max_shown_results = @options.max_shown_results || Number.POSITIVE_INFINITY
    @case_sensitive_search = @options.case_sensitive_search || false
    @hide_results_on_select = if @options.hide_results_on_select? then @options.hide_results_on_select else true
    @create_option = @options.create_option || false
    @persistent_create_option = @options.persistent_create_option || false
    @skip_no_results = @options.skip_no_results || false

  set_default_text: ->
    if @form_field.getAttribute("data-placeholder")
      @default_text = @form_field.getAttribute("data-placeholder")
    else if @is_multiple
      @default_text = @options.placeholder_text_multiple || @options.placeholder_text || AbstractChosen.default_multiple_text
    else
      @default_text = @options.placeholder_text_single || @options.placeholder_text || AbstractChosen.default_single_text

    @default_text = this.escape_html(@default_text)

    @results_none_found = @form_field.getAttribute("data-no_results_text") || @options.no_results_text || AbstractChosen.default_no_result_text
    @create_option_text = @form_field.getAttribute("data-create_option_text") || @options.create_option_text || AbstractChosen.default_create_option_text

  choice_label: (item) ->
    if @include_group_label_in_selected and item.group_label?
      "<b class='group-name'>#{item.group_label}</b>#{item.html}"
    else
      item.html

  mouse_enter: -> @mouse_on_container = true
  mouse_leave: -> @mouse_on_container = false

  input_focus: (evt) ->
    if @is_multiple
      setTimeout (=> this.container_mousedown()), 50 unless @active_field
    else
      @activate_field() unless @active_field

  input_blur: (evt) ->
    if not @mouse_on_container
      @active_field = false
      setTimeout (=> this.blur_test()), 100

  label_click_handler: (evt) =>
    if @is_multiple
      this.container_mousedown(evt)
    else
      this.activate_field()

  results_option_build: (options) ->
    content = ''
    shown_results = 0
    for data in @results_data
      data_content = ''
      if data.group
        data_content = this.result_add_group data
      else
        data_content = this.result_add_option data
      if data_content != ''
        shown_results++
        content += data_content

      # this select logic pins on an awkward flag
      # we can make it better
      if options?.first
        if data.selected and @is_multiple
          this.choice_build data
        else if data.selected and not @is_multiple
          this.single_set_selected_text(this.choice_label(data))

      if shown_results >= @max_shown_results
        break

    content

  result_add_option: (option) ->
    return '' unless option.search_match
    return '' unless this.include_option_in_results(option)

    classes = []
    classes.push "active-result" if !option.disabled and !(option.selected and @is_multiple)
    classes.push "disabled-result" if option.disabled and !(option.selected and @is_multiple)
    classes.push "result-selected" if option.selected
    classes.push "group-option" if option.group_array_index?
    classes.push option.classes if option.classes != ""

    option_el = document.createElement("li")
    option_el.className = classes.join(" ")
    option_el.style.cssText = option.style
    option_el.setAttribute("data-option-array-index", option.array_index)
    option_el.innerHTML = option.search_text
    option_el.title = option.title if option.title

    this.outerHTML(option_el)

  result_add_group: (group) ->
    return '' unless group.search_match || group.group_match
    return '' unless group.active_options > 0

    classes = []
    classes.push "group-result"
    classes.push group.classes if group.classes

    group_el = document.createElement("li")
    group_el.className = classes.join(" ")
    group_el.innerHTML = group.search_text
    group_el.title = group.title if group.title

    this.outerHTML(group_el)

  append_option: (option) ->
    this.select_append_option(option)

  results_update_field: ->
    this.set_default_text()
    this.results_reset_cleanup() if not @is_multiple
    this.result_clear_highlight()
    this.results_build()
    this.winnow_results() if @results_showing

  reset_single_select_options: () ->
    for result in @results_data
      result.selected = false if result.selected

  results_toggle: ->
    if @results_showing
      this.results_hide()
    else
      this.results_show()

  results_search: (evt) ->
    if @results_showing
      this.winnow_results()
    else
      this.results_show()

  winnow_results: ->
    this.no_results_clear()

    results = 0
    exact_result = false

    searchText = this.get_search_text()
    escapedSearchText = searchText.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")
    regex = this.get_search_regex(escapedSearchText)
    exactRegex = new RegExp("^#{escapedSearchText}$")
    highlightRegex = this.get_highlight_regex(escapedSearchText)

    for option in @results_data

      option.search_match = false
      results_group = null

      if this.include_option_in_results(option)

        if option.group
          option.group_match = false
          option.active_options = 0

        if option.group_array_index? and @results_data[option.group_array_index]
          results_group = @results_data[option.group_array_index]
          results += 1 if results_group.active_options is 0 and results_group.search_match
          results_group.active_options += 1

        option.search_text = if option.group then option.label else option.html

        unless option.group and not @group_search
          option.search_match = this.search_string_match(option.search_text, regex)
          results += 1 if option.search_match and not option.group

          exact_result = exact_result || exactRegex.test option.html

          if option.search_match
            if searchText.length
              startpos = option.search_text.search highlightRegex
              text = option.search_text.substr(0, startpos + searchText.length) + '</em>' + option.search_text.substr(startpos + searchText.length)
              option.search_text = text.substr(0, startpos) + '<em>' + text.substr(startpos)

            results_group.group_match = true if results_group?

          else if option.group_array_index? and @results_data[option.group_array_index].search_match
            option.search_match = true

    this.result_clear_highlight()

    if results < 1 and searchText.length
      this.update_results_content ""
      this.no_results searchText unless @create_option and @skip_no_results
    else
      this.update_results_content this.results_option_build()
      this.winnow_results_set_highlight()

    if @create_option and (results < 1 or (!exact_result and @persistent_create_option)) and searchText.length
      this.show_create_option( searchText )

  get_search_regex: (escaped_search_string) ->
    regex_anchor = if @search_contains then "" else "^"
    regex_flag = if @case_sensitive_search then "" else "i"
    new RegExp(regex_anchor + escaped_search_string, regex_flag)

  get_highlight_regex: (escaped_search_string) ->
    regex_anchor = if @search_contains then "" else "\\b"
    regex_flag = if @case_sensitive_search then "" else "i"
    new RegExp(regex_anchor + escaped_search_string, regex_flag)

  search_string_match: (search_string, regex) ->
    if regex.test search_string
      return true
    else if @enable_split_word_search and (search_string.indexOf(" ") >= 0 or search_string.indexOf("[") == 0)
      #TODO: replace this substitution of /\[\]/ with a list of characters to skip.
      parts = search_string.replace(/\[|\]/g, "").split(" ")
      if parts.length
        for part in parts
          if regex.test part
            return true

  choices_count: ->
    return @selected_option_count if @selected_option_count?

    @selected_option_count = 0
    for option in @form_field.options
      @selected_option_count += 1 if option.selected

    return @selected_option_count

  choices_click: (evt) ->
    evt.preventDefault()
    this.activate_field()
    this.results_show() unless @results_showing or @is_disabled

  keydown_checker: (evt) ->
    stroke = evt.which ? evt.keyCode
    this.search_field_scale()

    this.clear_backstroke() if stroke != 8 and @pending_backstroke

    switch stroke
      when 8 # backspace
        @backstroke_length = this.get_search_field_value().length
        break
      when 9 # tab
        this.result_select(evt) if @results_showing and not @is_multiple
        @mouse_on_container = false
        break
      when 13 # enter
        evt.preventDefault() if @results_showing
        break
      when 27 # escape
        evt.preventDefault() if @results_showing
        break
      when 32 # space
        evt.preventDefault() if @disable_search
        break
      when 38 # up arrow
        evt.preventDefault()
        this.keyup_arrow()
        break
      when 40 # down arrow
        evt.preventDefault()
        this.keydown_arrow()
        break

  keyup_checker: (evt) ->
    stroke = evt.which ? evt.keyCode
    this.search_field_scale()

    switch stroke
      when 8 # backspace
        if @is_multiple and @backstroke_length < 1 and this.choices_count() > 0
          this.keydown_backstroke()
        else if not @pending_backstroke
          this.result_clear_highlight()
          this.results_search()
        break
      when 13 # enter
        evt.preventDefault()
        this.result_select(evt) if this.results_showing
        break
      when 27 # escape
        this.results_hide() if @results_showing
        break
      when 9, 16, 17, 18, 38, 40, 91
        # don't do anything on these keys
      else
        this.results_search()
        break

  clipboard_event_checker: (evt) ->
    return if @is_disabled
    setTimeout (=> this.results_search()), 50

  container_width: ->
    return if @options.width? then @options.width else "#{@form_field.offsetWidth}px"

  include_option_in_results: (option) ->
    return false if @is_multiple and (not @display_selected_options and option.selected)
    return false if not @display_disabled_options and option.disabled
    return false if option.empty

    return true

  search_results_touchstart: (evt) ->
    @touch_started = true
    this.search_results_mouseover(evt)

  search_results_touchmove: (evt) ->
    @touch_started = false
    this.search_results_mouseout(evt)

  search_results_touchend: (evt) ->
    this.search_results_mouseup(evt) if @touch_started

  outerHTML: (element) ->
    return element.outerHTML if element.outerHTML
    tmp = document.createElement("div")
    tmp.appendChild(element)
    tmp.innerHTML

  get_single_html: ->
    """
      <a class="chosen-single chosen-default">
        <span>#{@default_text}</span>
        <div><b></b></div>
      </a>
      <div class="chosen-drop">
        <div class="chosen-search">
          <input class="chosen-search-input" type="text" autocomplete="off" />
        </div>
        <ul class="chosen-results"></ul>
      </div>
    """

  get_multi_html: ->
    """
      <ul class="chosen-choices">
        <li class="search-field">
          <input class="chosen-search-input" type="text" autocomplete="off" value="#{@default_text}" />
        </li>
      </ul>
      <div class="chosen-drop">
        <ul class="chosen-results"></ul>
      </div>
    """

  get_no_results_html: (terms) ->
    """
      <li class="no-results">
        #{@results_none_found} <span>#{terms}</span>
      </li>
    """

  # class methods and variables ============================================================

  @browser_is_supported: ->
    if "Microsoft Internet Explorer" is window.navigator.appName
      return document.documentMode >= 8
    return true

  @default_multiple_text: "Select Some Options"
  @default_single_text: "Select an Option"
  @default_no_result_text: "No results match"
  @default_create_option_text: "Add Option"
