var what = [
  "static websites", "landing pages", "Middleman websites", "Jekyll blogs",
  "Angular.js apps", "Ember.js apps", "Backbone.js apps", "single page apps"
]
var where = [
  "Heroku", "Dokku", "Flynn", "Digital Ocean VPS", "a dedicated server", "a VPS"
]

var randomizeArray = function(myArray) {
  myArray.sort(function() {
    return .5 - Math.random();
  });
  return myArray;
}

var updateText = function(selector, textArray, delay, index){
  index = typeof index !== 'undefined' ? index : 0;
  delay = typeof delay !== 'undefined' ? delay : 4000;


  selector.fadeOut(100, function(){
    selector.text(textArray[index]);
    selector.fadeIn(100);
  });

  setTimeout(function(){
    newIndex = index == textArray.length - 1 ? 0 : index + 1;
    updateText(selector, textArray, delay, newIndex);
  }, delay);
}

what = randomizeArray(what);
where = randomizeArray(where);

$("document").ready(function(){
  updateText($(".random.what"), what, 4000);
  // updateText($(".random.where"), where, 6000);
});
