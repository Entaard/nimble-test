const fetchAndSendKeywords = (csv) => {
  var data = csv.data;
  var keywords = [];

  for (i = 0; i < data.length; i++) {
    var row = data[i];
    var cells = row.join(',').split(',');

    for (j = 0; j < cells.length; j++) {
      keywords.push(cells[j]);
    }
  }

  sendKeywords(keywords);
};

const sendKeywords = (keywords) => {
  $.ajax({
    url: '/home/upload',
    method: 'POST',
    data: {
      keywords: keywords
    },
    success: (response) => {
      console.log('pushed to server');
    }
  });
};

const parseCSV = () => {
  $('#files').parse({
    config: {
      delimiter: 'auto',
      header: false,
      complete: fetchAndSendKeywords
    }
  });
};

$(document).ready(() => {
  $('#csvForm').submit((e) => {
    e.preventDefault();
    parseCSV();
  });
});
