let i = 0;

function timedCount() {
  i = i + 1;
  postMessage(i);
  setTimeout("timedCount()",500);
}

self.addEventListener("message", function(e) {
  console.log('in worker: ' + JSON.stringify(e.data));
});

timedCount();