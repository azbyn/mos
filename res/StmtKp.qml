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
            editor.add_if();
            editor.add_colon();
            editor.cursorLeft();
            back();
        }],
        ["else", function(){
            editor.add_else();
            editor.add_colon();
            back();
        }],
        ["fun", function(){
            /* fun [](|):
            */
            editor.add_fun();
            editor.add_lSquare();
            editor.add_rSquare();
            editor.add_lParen();
            var c = editor.getCursor();
            editor.add_rParen();
            editor.add_colon();
            editor.setCursorUnsafe(c);
            back();
        }],

        ["while", function(){
            editor.add_while();
            editor.add_colon();
            editor.cursorLeft();
            back();
        }],
        ["for", function(){
            editor.add_for();
            var c = editor.getCursor();
            editor.add_in();
            editor.add_colon();
            editor.setCursorUnsafe(c);
            back();
        }],
        ["in",       function(){ editor.add_in(); back(); }],
        ["return",   function(){ editor.add_return(); back(); }],
        ["break",    function(){ editor.add_break(); back(); }],
        ["continue", function(){ editor.add_continue(); back(); }],

    ]
}
