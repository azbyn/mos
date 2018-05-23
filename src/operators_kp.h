#ifndef OPERATORS_KP_H
#define OPERATORS_KP_H

#include "editor.h"
#include "font_size_data.h"

#include <QQuickPaintedItem>

class OperatorsKp : public QQuickPaintedItem {
    Q_OBJECT
private:
    enum State {
        Main,
        Misc,
        Math,
        Comp,
        Bool,
        Bitwise,
        Assign1,
        Assign2,

        Len
    } state = State::Main;
    struct BtnData {
        using Fun = void (*)(OperatorsKp*);
        QString name;
        Fun fun;
        BtnData(const QString& name, Fun fun) : name(name), fun(fun) {}
    };
    using StateData = std::vector<BtnData>;

    FontSizeData fsd;
    QFont font;
    int fontSize = 14;
    qreal r1, r2;
    // clang-format off
#define SD_SET_STATE(_str, _state) \
    {_str, [](OperatorsKp* k) { k->setState(State::_state); }}

#define SD_ADD_TOK(_str, _tt) \
    {_str, [](OperatorsKp* k) { k->back(); Editor::Instance->add_##_tt(); }}
#define SD_ADD_TOK2(_str, _tt1, _tt2)           \
    {_str, [](OperatorsKp* k) {                 \
            k->back();                      \
            Editor::Instance->add_##_tt1();     \
            Editor::Instance->add_##_tt2();     \
    }}

    // clang-format on

    const std::array<StateData, State::Len> stateDatas = {{
        //Main
        {{
            SD_ADD_TOK(".", dot),
            SD_ADD_TOK("=", assign),
            SD_SET_STATE("misc", Misc),
            SD_SET_STATE("& ^ |", Bitwise),
            SD_SET_STATE("+= **=", Assign1),
            SD_SET_STATE("~= |=", Assign2),
            SD_SET_STATE("+ %", Math),
            SD_SET_STATE("!= <", Comp),
        }},
        // Misc
        {{
            SD_ADD_TOK("~", tilde),
            SD_ADD_TOK2("?:", question, colon),
            SD_ADD_TOK2("[]", lSquare, rSquare),
        }},
        // Math
        {{
            SD_ADD_TOK("++", inc),
            SD_ADD_TOK("--", dec),
            SD_ADD_TOK("+", plus),
            SD_ADD_TOK("-", minus),
            SD_ADD_TOK("*", dot),
            SD_ADD_TOK("/", div),
            SD_ADD_TOK("//", intDiv),
            SD_ADD_TOK("%", mod),
            SD_ADD_TOK("**", pow),
        }},
        // Comp
        {{
            SD_ADD_TOK("==", eq),
            SD_ADD_TOK("!=", ne),
            SD_ADD_TOK("<", lt),
            SD_ADD_TOK(">", gt),
            SD_ADD_TOK("<=", le),
            SD_ADD_TOK(">=", ge),
        }},
        // Bool
        {{
            SD_ADD_TOK("&&", and),
            SD_ADD_TOK("||", or),
            SD_ADD_TOK("!", not),
        }},
        // Bitwise
        {{
            SD_ADD_TOK("^", xor),
            SD_ADD_TOK("&", bAnd),
            SD_ADD_TOK("|", bOr),
            SD_ADD_TOK("<<", lsh),
            SD_ADD_TOK(">>", rsh),
        }},
        //TODO remove these and convert ie '+' and '=' to '+='
        // Assign1
        {{
            SD_ADD_TOK("+=", plusEq),
            SD_ADD_TOK("-=", minusEq),
            SD_ADD_TOK("*=", mplyEq),
            SD_ADD_TOK("/=", divEq),
            SD_ADD_TOK("//=", intDivEq),
            SD_ADD_TOK("%=", modEq),
            SD_ADD_TOK("**=", powEq),
        }},
        // Assign2
        {{
            SD_ADD_TOK("~=", catEq),
            SD_ADD_TOK("<<=", lshEq),
            SD_ADD_TOK(">>=", rshEq),
            SD_ADD_TOK("&=", andEq),
            SD_ADD_TOK("|=", orEq),
            SD_ADD_TOK("^=", xorEq),
        }},
    }};
#undef SD_ADD_TOK
#undef SD_ADD_TOK2
#undef SD_SET_STATE
    const StateData& currStateData() const { return stateDatas[state]; }
    void setState(State state);
    void press(qreal x, qreal y);

public:
    explicit OperatorsKp(QQuickItem* parent = nullptr);
public slots:
    void back();

protected:
    void paint(QPainter* painter) override;
    void touchEvent(QTouchEvent* e) override;
    void mousePressEvent(QMouseEvent* e) override;

public:
signals:
    void gotoMain();
};

#endif
