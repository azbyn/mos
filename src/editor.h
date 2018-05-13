#ifndef EDITOR_H
#define EDITOR_H

#include "ts/ast/token.h"

#include <QObject>
#include <QPoint>

class Editor : public QObject {
    Q_OBJECT

private:
public:
    static Editor* instance;
    Editor();
    void addToken(TT type, const QString& msg = {});

public slots:
    void run();

public:
signals:
    void setOut(const QString& str);
    void appendOut(const QString& str);

};

#endif
