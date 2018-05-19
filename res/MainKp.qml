import QtQuick 2.0
import QtQuick.Controls 2.2
import ts 1.0

Keypad {
    //quickSize: 6
    quickData: [
        ["<-",   function(){ editorText.cursorLeft(); } ],
        ['->',   function(){ editorText.cursorRight(); } ],
        ["undo", function(){ } ],
        ["redo", function(){} ],
        ["find", function(){} ],
        ["del",  function(){ editorText.del(); } ],
    ]
    quickPerc: 0.1

    sizeX: 4
    sizeY: 3
    perc: 0.108 * sizeY
    btnData: [
        ["123",         function(){ ep.setCurr(KeypadType.Number); }],
        ['"str"',       function(){ ep.setCurr(KeypadType.String); }],
        ["other\nobjs", function(){ }],
        ["+-=",         function(){ }],

        ["vars",    function(){ ep.setCurr(KeypadType.Vars); }],
        ["libs",    function(){ ep.setCurr(KeypadType.Libs); }],
        ["if\nfor", function(){ ep.setCurr(KeypadType.Statements) }],
        ["\\n",     function(){ editorText.add_newLine(); }],

        [",", function(){
            editorText.add_comma();
        }],
        ["()", function(){
            editorText.addParenPair();
        }],
        ["{}", function(){
            editorText.addCurlyPair();
        }],
        [";", function(){
            editorText.add_terminator();
            editorText.add_newLine();
        }],
    ]
}
