import QtQuick 2.0
import QtQuick.Controls 2.2
import ts 1.0

Keypad {
    //quickSize: 6
    quickData: [
        ["<-",   function(){ editor.cursorLeft(); } ],
        ['->',   function(){ editor.cursorRight(); } ],
        ["undo", function(){ } ],
        ["redo", function(){} ],
        ["find", function(){} ],
        ["del",  function(){ editor.del(); } ],
    ]
    quickPerc: 0.1

    sizeX: 4
    sizeY: 3
    perc: 0.108 * sizeY
    btnData: [
        ["123",         function(){ ep.setCurr(KeypadType.Number); }],
        ['"str"',       function(){ ep.setCurr(KeypadType.String); }],
        ["other\nobjs", function(){ }],
        ["+-=",         function(){ ep.setCurr(KeypadType.Operators); }],

        ["vars",    function(){ ep.setCurr(KeypadType.Vars); }],
        ["libs",    function(){ ep.setCurr(KeypadType.Libs); }],
        ["if\nfor", function(){ ep.setCurr(KeypadType.Statements) }],
        ["\\n",     function(){ editor.add_newLine(); }],

        [",", function(){
            editor.add_comma();
        }],
        ["()", function(){
            editor.addParenPair();
        }],
        ["{}", function(){
            editor.addCurlyPair();
        }],
        [";", function(){
            editor.add_terminator();
            editor.add_newLine();
        }],
    ]
}
