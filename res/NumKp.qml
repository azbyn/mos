import QtQuick 2.0
import ts 1.0

Keypad {
    name: "num"
    quickData: [
        ["back", function(){ ep.setCurr(KeypadType.Main); } ],
        ["<-",   function(){ numText.cursorLeft(); } ],
        ['->',   function(){ numText.cursorRight() ;} ],
        ["del",  function(){ numText.del(); } ],
    ]
    quickPerc: 0.1

    sizeX: 3
    sizeY: 4
    perc: 0.425
    btnData: [
        ["7",  function(){ numText.addChar("7"); } ],
        ["8",  function(){ numText.addChar("8"); } ],
        ["9",  function(){ numText.addChar("9"); } ],

        ["4",  function(){ numText.addChar("4"); } ],
        ["5",  function(){ numText.addChar("5"); } ],
        ["6",  function(){ numText.addChar("6"); } ],

        ["1",  function(){ numText.addChar("1"); } ],
        ["2",  function(){ numText.addChar("2"); } ],
        ["3",  function(){ numText.addChar("3"); } ],

        [".",  function(){ numText.addChar("."); }],
        ["0",  function(){ numText.addChar("0"); }],
        ["OK", function(){ }],
    ]
}

