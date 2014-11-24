export function rows2json (rows)
  # At the first beginning, we don't have a foldr title.
  # so we are going to get the title before any other thing happens.
  got_title = false

  # #toc menu items are at root level by default.
  # if depth == 1, they will be in level 1 submenu (in accordion)
  depth = 0

  """
      var link_template_source ='<a href="{{url}}" target="{{target}}" id="{{id}}" class="{{type}} item"><i class="icon {{icon}}" data-content="{{subject}}"></i>{{subject}}</a>';
      //var link_template_source ='<a href="{{url}}" target="{{target}}" class="{{type}} item"><i class="icon {{icon}}"></i>{{subject}}</a>';
      var link_template = Handlebars.compile(link_template_source);

      var link_label_template_source ='<div class="ui label {{color}}">{{label}}</div>';
      var link_label_template = Handlebars.compile(link_label_template_source);

      // for link items
      var add_link = function(row_index, row){

        // prepare to handle link items. these variables will be used with link_template.
        var link_icon = "";
        var link_type = "link";
        var link_url = row[0].trim();

        // parse link options. version 1
        //try{
        //  var link_options = JSON.parse(row[2]);
        //}catch(e){
        //  var link_options = {};
        //}
        // apply additional link options set in column c... well, since there seems to be only one possible option (target), i would like to make it easier to setup... how about just writing "blank" keyword?
        //for(key in link_options){
        //  $link_element.attr(key, link_options[key]);
        //}

        // parse link options. version 2
        if(row[2].match(/blank/)){
          var link_target = "_blank";
        }else{
          var link_target = "iframe";
        }

        // automatically assign various of pretty icons for link items
        if(link_url.match(/^.*.hackpad.com\//)){
          link_icon = "text file outline";
        } else if(link_url.match(/^.*.etherpad.mozilla.org\//)) {
          link_icon = "file outline";
        } else if(link_url.match(/^.*.groups.google.com\//)) {
          link_icon = "users";
        } else if(link_url.match(/^.*.plus.google.com\//)) {
          link_icon = "google plus";
        } else if(link_url.match(/^.*.kktix.cc\//)) {
          link_icon = "bullhorn";
        } else if(link_url.match(/^.*.kktix.com\//)) {
          link_icon = "bullhorn";
        } else if(link_url.match(/^.*.registrano.com\//)) {
          link_icon = "bullhorn";
        } else if(link_url.match(/^.*.docs.google.com\/spreadsheet.*/)) {
          link_icon = "table";
        } else if(link_url.match(/^.*.docs.google.com\/drawings.*/)) {
          link_icon = "photo";
        } else if(link_url.match(/^.*.docs.google.com\/document.*/)) {
          link_icon = "text file";
        } else if(link_url.match(/^.*.docs.google.com\/presentation.*/)) {
          link_icon = "laptop";
        } else if(link_url.match(/^.*.docs.google.com\/form.*/)) {
          link_icon = "unordered list";
        } else if(link_url.match(/^.*.drive.google.com\//)) {
          link_icon = "cloud";
        } else if(link_url.match(/^.*.mapsengine.google.com\//)) {
          link_icon = "map marker";
        } else if(link_url.match(/^.*.www.google.com\/maps\//)) {
          link_icon = "map marker";
        } else if(link_url.match(/^.*.umap.fluv.io\//)) {
          link_icon = "map marker";
        } else if(link_url.match(/^.*.github.com\//)) {
          link_icon = "github";
        } else if(link_url.match(/^.*.moqups.com\//)) {
          link_icon = "photo";
        } else if(link_url.match(/^.*.facebook.com\//)) {
          link_icon = "facebook";
        } else if(link_url.match(/^.*.twitter.com\//)) {
          link_icon = "twitter";
        } else if(link_url.match(/^.*.tumblr.com\//)) {
          link_icon = "tumblr";
        } else if(link_url.match(/^.*.trello.com\//)) {
          link_icon = "trello";
        } else if(link_url.match(/^.*.youtube.com\/embed\//)) {
          link_icon = "youtube play";
        } else if(link_url.match(/^.*.youtube.com\//)) {
          var startPostition = link_url.indexOf('v=') + 2;
          link_url = '//www.youtube.com/embed/' + link_url.substring(startPostition, startPostition + 11);
          link_icon = "youtube play";
        } else if(link_url.match(/^.*.flickr.com\//)) {
          link_icon = "flickr";
        } else if(link_url.match(/^.*.ustream.tv\//)) {
          link_icon = "facetime video";
        } else if(link_url.match(/^.*.www.justin.tv\//)) {
          link_icon = "facetime video";
        } else if(link_url.match(/^.*.www.ptt.cc\/bbs\//)) {
          link_icon = "chat outline";
        } else if(link_url.match(/^.*.disp.cc\//)) {
          link_icon = "chat outline";
        } else if(link_url.match(/^.*.www.google.com\/moderator\//)) {
          link_icon = "chat outline";
        } else if(link_url.match(/^.*.www.loomio.org\//)) {
          link_icon = "chat outline";
        } else if(link_url.match(/^.*.hack.g0v.tw\//)) {
          link_icon = "exchange";
          //link_url = link_url.split("/")[1].toString();
          //link_type = "foldr";
          //link_target = "";
        } else if(link_url.match(/^.*.hack.etblue.tw\//)) {
          link_icon = "exchange";
          //link_url = link_url.split("/")[1].toString();
          //link_type = "foldr";
          //link_target = "";
        } else if(link_url.match(/^.*.hackfoldr.org\//)) {
          link_icon = "exchange";
          //link_url = link_url.split("/")[1].toString();
          //link_type = "foldr";
          //link_target = "";
        } else {
          link_icon = "globe";
        }

        // wrap up link item optinos into a hash
        var context = {id: row_index+1, url: link_url, subject: row[1], icon: link_icon, type: link_type, target: link_target};
        // and send it into the html template (meanwhile, assign it an id for jquery sortable)        
        var $link_element = $(link_template(context));

        // parse link labels
        var link_label = row[3].trim();
        var link_label_color = "";

        if(link_label.length > 0){
          // set up label color
          if(link_label.match(/^gray/) || link_label.match(/:issue/)){
            link_label_color = "gray";
          }else if(link_label.match(/^deep-blue/)){
            link_label_color = "deep-blue";
          }else if(link_label.match(/^deep-green/)){
            link_label_color = "deep-green";
          }else if(link_label.match(/^deep-purple/)){
            link_label_color = "deep-purple";
          }else if(link_label.match(/^black/)){
            link_label_color = "black";
          }else if(link_label.match(/^green/)){
            link_label_color = "green";
          }else if(link_label.match(/^red/) || link_label.match(/:important/)){
            link_label_color = "red";
          }else if(link_label.match(/^blue/)){
            link_label_color = "blue";
          }else if(link_label.match(/^orange/)){
            link_label_color = "orange";
          }else if(link_label.match(/^purple/)){
            link_label_color = "purple";
          }else if(link_label.match(/^teal/)){
            link_label_color = "teal";
          }else if(link_label.match(/^yellow/) || link_label.match(/:warning/)){
            link_label_color = "yellow";
          }else if(link_label.match(/^pink/)){
            link_label_color = "pink";
          };
          // set up label content
          link_label = link_label.replace(link_label_color,"").replace("important","").replace("warning","").replace("issue","").replace(":","").trim();
          // append label to link item
          var label_context = {label: link_label, color: link_label_color};
          var $link_label_element = $(link_label_template(label_context));
          $link_element.find("i.icon").after($link_label_element);
        }

        // append link item to #toc menu
        if(depth == 1){
          $('#toc .ui.accordion:last').find('.menu').append($link_element);
        }else{
          $('#toc .ui.vertical.menu').append($link_element);
        }

        // set iframe src?
        if(current_iframe_url == "edit"){
          if(csv_api_source_type=="ethercalc"){
            iframe_src = 'https://ethercalc.org/'+csv_api_source_id;
          }else{
            iframe_src = 'https://docs.google.com/spreadsheets/d/'+csv_api_source_id+'/edit';
          };
          $("title").text("編輯 | "+current_foldr_name+" | hackfoldr");
          $("#topbar .edit.table").hide();
          $("#topbar .refresh.table").show();
          $("#topbar .add.to.list").show();
        }else if((new RegExp(context.url+"/?")).test(current_iframe_url)){
          iframe_src = current_iframe_url;
        }else if(/^https:\/\/.*.hackpad.com\//.test(context.url)){
          if( current_iframe_url === context.url.split(/\//).pop()){
            iframe_src = context.url;
          }
        }
        // the very first link href would be default iframe_src
        if(!iframe_src) {
          iframe_src = context.url;
        }
      }
      
      var accordion_template_source = '<div class="ui accordion"><div id="{{id}}" class="title header item {{mode}}"><i class="icon folder closed"></i><i class="icon folder open hidden" data-content="{{title}}" style="display: none;"></i>{{title}}</div><div class="content ui small sortable menu {{mode}}"></div></div>';      var accordion_template = Handlebars.compile(accordion_template_source);

      // for foldr items
      var add_accordion = function(row_index, row){

        // foldr options, version 1
        //try{
        //  var options = JSON.parse(row[2]);
        //}catch(e){
        //  var options = {};
        //}
        // foldr options, version 2
        if(row[2].match(/expand/)){
          var foldr_mode = "active";
        }else if(row[2].match(/collapse/)){
          var foldr_mode = "collapsed-subfoldr";
        }else{
          var foldr_mode = "";
        }

        var context = {title: row[1], id: row_index+1, mode: foldr_mode};
        var $accordion_el = $(accordion_template(context));

        // append foldr item to #toc menu
        $accordion_el.appendTo('#toc .ui.vertical.menu').accordion();

        // expand foldr item if "expand" is set to its option
        //if(foldr_mode){
        //  $accordion_el.accordion('open',0)
        //}
      }

      // start creating #toc menu
      $.each(rows, function(row_index, row){

        // prepare column A - D for following actions
        if(!row[0]){
          row[0] = "";
        }
        if(!row[1]){
          row[1] = "";
        }
        if(!row[2]){
          row[2] = "";
        }
        if(!row[3]){
          row[3] = "";
        }

        row = row.map(function (content) {
          return content.toString();
        });

        // skip comment rows
        if(row[0].match(/^#/) || row[1].match(/^#/) || row[2].match(/^#/) || row[3].match(/^#/)){
          return
        }

        var this_row_url = row[0].trim();
        var this_row_title = row[1].trim();
        console.log(row[0]);

        // if column A and B is empty, then skip this row 
        if(this_row_url.length === 0 && this_row_title.length === 0){
          return
        }

        // if anyone of column A and B is not empty, then parse this row
        // if foldr title is not set yet, then the content of first non-empty row would be foldr title
        if(!got_title){

          if(this_row_title.length > 0){

            // make the first non-comment content foldr title 
            $('#topbar .foldr.title .text').text(this_row_title);
            current_foldr_name = this_row_title;
            got_title = true;

            // detect sheet hide option
            if(row[2].match(/hide/)) {
              hide_sheet = true;
            }

            // detect sheet sort option
            if(row[2].match(/unsortable/)) {
              sort_sheet = false;
            }

            // detect title row index, not using
            //new_pad_row_index = row_index+2;

            // save current foldr info
            var current_foldr_history = {
              foldr_name: this_row_title,
              foldr_id: ethercalc_name
            };

            // Remove all items in foldr_histories that share the same foldr_id
            foldr_histories = $.grep(foldr_histories, function(value){
              return JSON.parse(value).foldr_id !== current_foldr_history.foldr_id;
            });
            // new history on top
            foldr_histories.unshift(JSON.stringify(current_foldr_history));
            // add foldr to history
            localStorage.setItem("hackfoldr", JSON.stringify(foldr_histories));
          }else{
            return
          }

          // TODO: need opt....
          //$.each(row, function(col_index, col){
          //  col = col.trim();
          //  // get the MAGIC title
          //  if(!got_title && col.length > 0) {
          //  }
          //});
        } else {
          // since foldr title is set, start to get links in #toc
          if(this_row_url.length == 0 || this_row_url.match(/^>/)){ // folder 
            depth = 1
            add_accordion(row_index, row);
          }else if(this_row_url.match(/^</)){ // end folder
            depth = 0
          }else { // link
            add_link(row_index, row);
            // set initial page title
            if(this_row_url == iframe_src){
              if(iframe_src == "edit"){
                $("title").text("編輯 | "+current_foldr_name+" | hackfoldr");
              }else{
                $("title").text(this_row_title+" | "+current_foldr_name+" | hackfoldr");
              }
            }
          }
        }
      });

      // set initial iframe src attribute
      if(!$("#iframe").attr("src")){
        $("#iframe").attr("src",iframe_src);
      }

      // auto new window, and auto new window icon
      var new_window_icon = "<i class='icon forward mail'></i>";
      var open_link_in_new_window_or_not = function(){
        link_url = $(this).attr("href");
        if(link_url.match(/^.*.plus.google.com\//)) {
          return true;
        } else if(link_url.match(/^.*.kktix.cc\//)) {
          return true;
        } else if(link_url.match(/^.*.kktix.com\//)) {
          return true;
        } else if(link_url.match(/^.*.registrano.com\//)) {
          return true;
        } else if(link_url.match(/^.*.github.com\//)) {
          return true;
        } else if(link_url.match(/^.*.drive.google.com\//)) {
          return true;
        } else if(link_url.match(/^.*.facebook.com\//)) {
          return true;
        } else if(link_url.match(/^.*.trello.com\//)) {
          return true;
        } else if(link_url.match(/^.*.youtube.com\/playlist.*/)) {
          return true;
        //} else if(link_url.match(/^.*.gov.tw\//)) {
        //  return true;
        } else if(link_url.match(/^.*.www.loomio.org\//)) {
          return true;
        } else if(link_url.match(/^.*.flickr.com\//)) {
          return true;
        } else {
          return false;
        }
      };
      $("#toc a.link.item").filter(open_link_in_new_window_or_not).attr("target","_blank").find("i.icon").after(new_window_icon);
      $("#toc a.link.item[target='_blank']").not(":has(i.icon.forward.mail)").find("i.icon").after(new_window_icon);

      // auto highlight active items and expand parent accordion
      var link_is_current_url_or_not = function(){
        link_url = $(this).attr("href");
        if(link_url == iframe_src){
          return true;
        } else {
          return false;
        }
      };
      $("#toc a.link.item").filter(link_is_current_url_or_not).addClass("active").parent(".content").addClass("active").prev(".header").addClass("active");

      // auto expand #toc accordion when number < 4
      var children_are_less_or_not = function(){
        if($(this).children().length<4){
          return true;
        }else{
          return false;
        }
      };
      $("#toc .ui.accordion .content").filter(children_are_less_or_not).not(".collapsed-subfoldr").addClass("active").prev(".header").addClass("active");

      // change foldr icons for auto activated subfoldrs
      $("#toc .ui.accordion .header.active .icon.folder.closed").hide();
      $("#toc .ui.accordion .header.active .icon.folder.open").show();

      // make #toc sortable on edit page by default
      if(current_iframe_url == "edit"){
        if(csv_api_source_type=="ethercalc"){
          if(sort_sheet){
            $("#toc .sortable").sortable(sort_action);
          }
        }
      }

      // enable popup
      $('i.icon').popup();
    }
  """
