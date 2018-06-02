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
        Math,
        Comp,
        Bool,
        Bitwise,

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

#define SD_ADD_TOK(_str, _tt)                   \
    {_str, [](OperatorsKp* k) {                 \
            k->gotoMain();                      \
            k->setState(State::Main);           \
            Editor::Instance->add##_tt();      \
        }}
#define SD_ADD_TOK2(_str, _tt1, _tt2)           \
    {_str, [](OperatorsKp* k) {                 \
            k->gotoMain();                      \
            k->setState(State::Main);           \
            Editor::Instance->add##_tt1();     \
            Editor::Instance->add##_tt2();     \
    }}

    // clang-format on

    const std::array<StateData, State::Len> stateDatas = {{
        //Main
        {{
            SD_ADD_TOK(".", Dot),
            SD_ADD_TOK("~", Tilde),
            SD_ADD_TOK2("?:", Question, Colon),
            SD_ADD_TOK2("[]", LSquare, RSquare),
            SD_SET_STATE("& ^ |", Bitwise),
            SD_SET_STATE("&& || !", Bool),
            SD_SET_STATE("+ %", Math),
            SD_SET_STATE("!= <", Comp),
        }},
        // Math
        {{
            SD_ADD_TOK("++", Inc),
            SD_ADD_TOK("--", Dec),
            SD_ADD_TOK("+", Plus),
            SD_ADD_TOK("-", Minus),
            SD_ADD_TOK("*", Dot),
            SD_ADD_TOK("/", Div),
            SD_ADD_TOK("//", IntDiv),
            SD_ADD_TOK("%", Mod),
            SD_ADD_TOK("**", Pow),
        }},
        // Comp
        {{
            SD_ADD_TOK("==", Eq),
            SD_ADD_TOK("!=", Ne),
            SD_ADD_TOK("<", Lt),
            SD_ADD_TOK(">", Gt),
            SD_ADD_TOK("<=", Le),
            SD_ADD_TOK(">=", Ge),
        }},
        // Bool
        {{
            SD_ADD_TOK("&&", And),
            SD_ADD_TOK("||", Or),
            SD_ADD_TOK("!", Not),
        }},
        // Bitwise
        {{
            SD_ADD_TOK("^", Xor),
            SD_ADD_TOK("&", BAnd),
            SD_ADD_TOK("|", BOr),
            SD_ADD_TOK("<<", Lsh),
            SD_ADD_TOK(">>", Rsh),
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
