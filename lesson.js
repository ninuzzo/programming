var lpfa = {
  $: function(id) { return document.getElementById(id); },

  load_json: function(url) {
    var xmlhttp = new XMLHttpRequest();

    xmlhttp.open('GET', url, false);
    xmlhttp.send();

    return JSON.parse(xmlhttp.responseText);
  },

  gen_menu: function() {
    this.index = this.load_json('lessons/index.json');
    for (var i = 0; i < this.index.length; i++) {
      document.write((i ? ' | ' : '') + '<a href="javascript:void(0)" title="'
        + this.index[i] + '" onclick="lpfa.load_lesson(' + i + ')">' + (i + 1)
        + '</a>');
    }
  },

  display_slide: function() {
    with (this) {
      var imgname = lesson[slide_no][0];
      $('lpfa_image').src = lesson_path + imgname 
        + (typeof imgname == 'number' ? '.png' : '');
      $('lpfa_text').innerHTML = lesson[slide_no][1];
      $('lpfa_slideno').value = slide_no + 1;
      window.history.replaceState({}, document.title, window.location.pathname
        + '?' + (lesson_number + 1) + '&' + (slide_no + 1));
    }
  },

  load_lesson: function(number, init_slide) {
    init_slide = init_slide || 0;
    with (this) {
      lesson_number = number;
      $('lpfa_number').textContent = number + 1;
      $('lpfa_title').textContent = index[number];
      lesson_path = 'lessons/' + (lesson_number + 1) + '/';
      lesson = load_json(lesson_path + 'data.json');
      slide_no = init_slide;
      display_slide();
      $('lpfa_controls').style.display = 'block';
      $('lpfa_slideno').max = lesson.length;
    }
  },

  prev_slide: function() {
    with (this) {
      if (slide_no) {
        slide_no--;
        display_slide();
      } else if (lesson_number) {
        load_lesson(--lesson_number);
      }
    }
  },

  next_slide: function() {
    with (this) {
      if (slide_no < lesson.length - 1) {
        slide_no++;
        display_slide();
      } else if (lesson_number < index.length - 1) {
        load_lesson(++lesson_number);
      }
    }
  },

  go: function() {
    with (this) {
      slide_no = $('lpfa_slideno').value - 1;
      if (slide_no < 0) {
        slide_no = 0;
      } else if (slide_no >= lesson.length) {
        slide_no = lesson.length - 1;
      }
      display_slide();
    }
  },
};

window.addEventListener('keydown', function(e) {
  switch (e.keyCode) {
    case 8: // backspace
    case 'p':
    case 'P':
      e.preventDefault();
      lpfa.prev_slide();
      break;
    case 13: // enter
    case 32: // spacebar
    case 'n':
    case 'N':
      e.preventDefault();
      lpfa.next_slide();
      break;
  }
});

window.addEventListener('load', function() {
  var bookmark = window.location.search.substring(1).split('&');
  if (bookmark.length == 2) {
    lpfa.load_lesson(bookmark[0] - 1, bookmark[1] - 1);
  }
});
