const api_url = "https://8659-217-21-43-71.eu.ngrok.io"

function req_ts_()
{
    var radios = document.getElementsByName('hash');
    var url_ = api_url + "bpki/req_ts?"
    for (var i = 0, length = radios.length; i < length; i++) {
        if (radios[i].checked) {
            url_ += "hash=" + radios[i].value;
            break;
        }
    }

    url_ += "&file=" + document.getElementById("file").value;

    var radios = document.getElementsByName('nonce');
    for (var i = 0, length = radios.length; i < length; i++) {
        if (radios[i].checked) {
            url_ += "&nonce=" + radios[i].value;
            break;
        }
    }
    // console.log(url);
    // window.open(url);
    // location.href = url;
    $.ajax({
        type: "GET",
        url: url_,
        success: function (result) {
          console.log(result);
        },
        error: function (result, status) {
          console.log(result);
        }
      });
}

function enroll1()
{
    let data_to_send = document.getElementById("textArea").value;
    let url_ = api_url + "/bpki/enroll1";
    let req = $.ajax({
      method: "POST",
      url: api_url + "\/bpki\/enroll1",
      data: JSON.stringify({ "request": data_to_send }),
      contentType: "application/json",
      success: function (result) {
        console.log(result);
      },
      error: function (result, status) {
        console.log(result);
      }
    });
}

const input = document.getElementById("selectConfig");
const textArea = document.getElementById("textArea");
const textAreaPreview = document.getElementById("textAreaPreview");

const convertBase64 = (file) => {
    return new Promise((resolve, reject) => {
        const fileReader = new FileReader();
        fileReader.readAsDataURL(file);

        fileReader.onload = () => {
            resolve(fileReader.result);
        };

        fileReader.onerror = (error) => {
            reject(error);
        };
    });
};

const getData = (file) => {
    return new Promise((resolve, reject) => {
        const fileReader = new FileReader();
        fileReader.readAsText(file);

        fileReader.onload = () => {
            resolve(fileReader.result);
        };

        fileReader.onerror = (error) => {
            reject(error);
        };
    });
};

const uploadFile = async (event) => {
    const file = event.target.files[0];
    textAreaPreview.innerText = await getData(file);
    const base64 = await convertBase64(file);
    textArea.innerText = base64;
};

input.addEventListener("change", (e) => {
    uploadFile(e);
});