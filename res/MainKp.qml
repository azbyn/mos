import QtQuick 2.0
import QtQuick.Controls 2.2
import ts 1.0

Keypad {
    name: "main"
    //quickSize: 6
    quickData: [
        ["<-",   function(){ editorText.cursorLeft(); } ],
        ['->',   function(){ editorText.cursorRight(); } ],
        ["undo", function(){} ],
        ["redo", function(){} ],
        ["find", function(){} ],
        ["del",  function(){} ],
    ]
    quickPerc: 0.1

    sizeX: 4
    sizeY: 3
    perc: 0.325
    btnData: [
        ["123",         function(){ ep.setCurr(KeypadType.Number); } ],
        ['"str"',       function(){ editorText.setStr("hello"); } ],
        ["other\nobjs", function(){ color = "black"; } ],
        ["+-=",         function(){ ep.setCurr(KeypadType.Number); } ],

        ["\\n",     function(){} ],
        ["vars",    function(){} ],
        ["libs",    function(){} ],
        ["if\nfor", function(){} ],

        [";",   function(){}],
        ["{}",  function(){}],
        ["()",  function(){}],
        [",",   function(){}],
    ]
}
