#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "promptmanager.h"
#include "projectcomparator.h"
#include "compilererrorprocessor.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<PromptManager>("PromptManager", 1, 0, "PromptManager");
    qmlRegisterType<ProjectComparator>("ProjectComparator", 1, 0, "ProjectComparator");
    qmlRegisterType<CompilerErrorProcessor>("CompilerErrorProcessor", 1, 0, "CompilerErrorProcessor");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
