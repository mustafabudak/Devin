#ifndef COMPILERERRORPROCESSOR_H
#define COMPILERERRORPROCESSOR_H

#include <QObject>
#include <QString>
#include <QStringList>

class CompilerErrorProcessor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString errorText READ errorText WRITE setErrorText NOTIFY errorTextChanged)
    Q_PROPERTY(QString processedPrompt READ processedPrompt NOTIFY processedPromptChanged)

public:
    explicit CompilerErrorProcessor(QObject *parent = nullptr);

    QString errorText() const;
    void setErrorText(const QString &text);
    QString processedPrompt() const;

    Q_INVOKABLE void processErrors();
    Q_INVOKABLE void loadErrorsFromFile(const QString &filePath);
    Q_INVOKABLE void generateFixPrompt();

signals:
    void errorTextChanged();
    void processedPromptChanged();
    void promptGenerated(const QString &prompt);
    void errorOccurred(const QString &error);

private:
    QString m_errorText;
    QString m_processedPrompt;
    
    struct CompilerError {
        QString file;
        int line;
        QString type;
        QString message;
        QString code;
    };
    
    QList<CompilerError> parseErrors(const QString &errorText);
    QString formatErrorsForAI(const QList<CompilerError> &errors);
    CompilerError parseGccError(const QString &errorLine);
    CompilerError parseMsvcError(const QString &errorLine);
    CompilerError parseClangError(const QString &errorLine);
};

#endif // COMPILERERRORPROCESSOR_H
