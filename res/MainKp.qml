import QtQuick 2.0
import QtQuick.Controls 2.2
import mos 1.0

Keypad {
    //quickSize: 6
    quickData: [
        ["<-",   function(){ editor.cursorLeft(); } ],
        ['->',   function(){ editor.cursorRight(); } ],
        ["undo", function(){ } ],
        ["redo", function(){} ],
        ["find", function(){} ],
        ["⌫",  function(){ editor.del(); } ],
    ]
    quickPerc: 0.1

    sizeX: 4
    sizeY: 3
    perc: 0.108 * sizeY
    btnData: [
        ["123",            function(){ ep.setCurr(KeypadType.Number); }],
        ['"str"',          function(){ ep.setCurr(KeypadType.String); }],
        ["true λ\nfun {}", function(){ ep.setCurr(KeypadType.OtherObjs) }],
        ["> + -\n % =",    function(){ ep.setCurr(KeypadType.Operators); }],

        ["vars",    function(){ ep.setCurr(KeypadType.Vars); }],
        ["libs",    function(){ ep.setCurr(KeypadType.Libs); }],
        ["if\nfor", function(){ ep.setCurr(KeypadType.Statements) }],
        ["\\n",     function(){ editor.addNewLine(); }],

        [",", function(){
            editor.addComma();
        }],
        ["()", function(){
            editor.addParenPair();
        }],
        ["=", function(){
            editor.addAssign();
            //editor.addCurlyPair();
        }],
        ["\\t",     function(){ editor.addIndent(); }],
    ]
}
