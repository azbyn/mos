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
    void puts(const QString& value);
public slots:
    void run();

public:
signals:
    void setOut(const QString& value);
    void appendOut(const QString& value);

};

void tsputs(const ushort* sh, size_t len);

#endif
