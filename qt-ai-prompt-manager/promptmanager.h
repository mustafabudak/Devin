#ifndef PROMPTMANAGER_H
#define PROMPTMANAGER_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class PromptManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentPrompt READ currentPrompt WRITE setCurrentPrompt NOTIFY currentPromptChanged)
    Q_PROPERTY(QString simplifiedPrompt READ simplifiedPrompt NOTIFY simplifiedPromptChanged)

public:
    explicit PromptManager(QObject *parent = nullptr);

    QString currentPrompt() const;
    void setCurrentPrompt(const QString &prompt);
    QString simplifiedPrompt() const;

    Q_INVOKABLE void simplifyPrompt();
    Q_INVOKABLE void sendToAI(const QString &service, const QString &apiKey);
    Q_INVOKABLE void loadPromptFromFile(const QString &filePath);
    Q_INVOKABLE void savePromptToFile(const QString &filePath);

signals:
    void currentPromptChanged();
    void simplifiedPromptChanged();
    void aiResponseReceived(const QString &response);
    void errorOccurred(const QString &error);

private slots:
    void handleNetworkReply();

private:
    QString m_currentPrompt;
    QString m_simplifiedPrompt;
    QNetworkAccessManager *m_networkManager;

    QString simplifyText(const QString &text);
    void sendToOpenAI(const QString &prompt, const QString &apiKey);
    void sendToClaude(const QString &prompt, const QString &apiKey);
};

#endif // PROMPTMANAGER_H
