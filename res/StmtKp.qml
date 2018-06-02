import QtQuick 2.0
import QtQuick.Controls.Styles 1.0
import ts 1.0

Keypad {
    /*function okBttn() {
        return btnAt(11);
    }*/
    /*
    Component.onCompleted: {
        okBttn().font.bold = true;
        invalidate();
    }
    function validate() {
        okBttn().txtColor = "green";
    }
    function invalidate() {
        okBttn().txtColor = "red";
    }
*/
    function back(){
        ep.setCurr(KeypadType.Main);
    }

    quickData: [
        ["back", function(){ back(); } ],
        ["<-",   function(){ editor.cursorLeft(); } ],
        ["->",   function(){ editor.cursorRight() ;} ],
        ["undo", function(){}],
        ["redo", function(){}],
        ["⌫",  function(){ editor.del(); } ],
    ]
    quickPerc: 0.1

    sizeX: 3
    sizeY: 3
    perc: 0.108 * sizeY
    btnData: [
        ["if", function(){
            editor.addIf();
            editor.addColon();
            editor.cursorLeft();
            back();
        }],
        ["else", function(){
            editor.addElse();
            editor.addColon();
            back();
        }],
        ["fun", function(){
            /* fun [](|):
            */
            editor.addFun();
            editor.addLSquare();
            editor.addRSquare();
            editor.addLParen();
            var c = editor.getCursor();
            editor.addRParen();
            editor.addColon();
            editor.setCursorUnsafe(c);
            back();
        }],

        ["while", function(){
            editor.addWhile();
            editor.addColon();
            editor.cursorLeft();
            back();
        }],
        ["for", function(){
            editor.addFor();
            var c = editor.getCursor();
            editor.addIn();
            editor.addColon();
            editor.setCursorUnsafe(c);
            back();
        }],
        ["in",       function(){ editor.addIn(); back(); }],
        ["return",   function(){ editor.addReturn(); back(); }],
        ["break",    function(){ editor.addBreak(); back(); }],
        ["continue", function(){ editor.addContinue(); back(); }],

    ]
}
