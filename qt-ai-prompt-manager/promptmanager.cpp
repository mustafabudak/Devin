#include "promptmanager.h"
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>

PromptManager::PromptManager(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
{
    connect(m_networkManager, &QNetworkAccessManager::finished,
            this, &PromptManager::handleNetworkReply);
}

QString PromptManager::currentPrompt() const
{
    return m_currentPrompt;
}

void PromptManager::setCurrentPrompt(const QString &prompt)
{
    if (m_currentPrompt != prompt) {
        m_currentPrompt = prompt;
        emit currentPromptChanged();
    }
}

QString PromptManager::simplifiedPrompt() const
{
    return m_simplifiedPrompt;
}

void PromptManager::simplifyPrompt()
{
    m_simplifiedPrompt = simplifyText(m_currentPrompt);
    emit simplifiedPromptChanged();
}

QString PromptManager::simplifyText(const QString &text)
{
    QString simplified = text;
    
    simplified = simplified.simplified();
    
    QStringList redundantPhrases = {
        "please", "could you", "would you", "can you",
        "I would like", "I want", "I need"
    };
    
    for (const QString &phrase : redundantPhrases) {
        QRegularExpression re("\\b" + QRegularExpression::escape(phrase) + "\\b", 
                             QRegularExpression::CaseInsensitiveOption);
        simplified.replace(re, "");
    }
    
    simplified.replace(QRegularExpression("\\s+"), " ");
    simplified = simplified.trimmed();
    
    if (!simplified.isEmpty()) {
        simplified = "Task: " + simplified;
        if (!simplified.endsWith(".")) {
            simplified += ".";
        }
    }
    
    return simplified;
}

void PromptManager::sendToAI(const QString &service, const QString &apiKey)
{
    if (m_simplifiedPrompt.isEmpty()) {
        emit errorOccurred("No prompt to send. Please simplify a prompt first.");
        return;
    }
    
    if (service.toLower() == "openai") {
        sendToOpenAI(m_simplifiedPrompt, apiKey);
    } else if (service.toLower() == "claude") {
        sendToClaude(m_simplifiedPrompt, apiKey);
    } else {
        emit errorOccurred("Unsupported AI service: " + service);
    }
}

void PromptManager::sendToOpenAI(const QString &prompt, const QString &apiKey)
{
    QNetworkRequest request(QUrl("https://api.openai.com/v1/chat/completions"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + apiKey).toUtf8());
    
    QJsonObject json;
    json["model"] = "gpt-3.5-turbo";
    json["max_tokens"] = 1000;
    
    QJsonArray messages;
    QJsonObject message;
    message["role"] = "user";
    message["content"] = prompt;
    messages.append(message);
    json["messages"] = messages;
    
    QJsonDocument doc(json);
    m_networkManager->post(request, doc.toJson());
}

void PromptManager::sendToClaude(const QString &prompt, const QString &apiKey)
{
    QNetworkRequest request(QUrl("https://api.anthropic.com/v1/messages"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("x-api-key", apiKey.toUtf8());
    request.setRawHeader("anthropic-version", "2023-06-01");
    
    QJsonObject json;
    json["model"] = "claude-3-sonnet-20240229";
    json["max_tokens"] = 1000;
    
    QJsonArray messages;
    QJsonObject message;
    message["role"] = "user";
    message["content"] = prompt;
    messages.append(message);
    json["messages"] = messages;
    
    QJsonDocument doc(json);
    m_networkManager->post(request, doc.toJson());
}

void PromptManager::handleNetworkReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;
    
    if (reply->error() == QNetworkReply::NoError) {
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject obj = doc.object();
        
        QString response;
        if (obj.contains("choices")) {
            QJsonArray choices = obj["choices"].toArray();
            if (!choices.isEmpty()) {
                response = choices[0].toObject()["message"].toObject()["content"].toString();
            }
        } else if (obj.contains("content")) {
            QJsonArray content = obj["content"].toArray();
            if (!content.isEmpty()) {
                response = content[0].toObject()["text"].toString();
            }
        }
        
        emit aiResponseReceived(response);
    } else {
        emit errorOccurred("Network error: " + reply->errorString());
    }
    
    reply->deleteLater();
}

void PromptManager::loadPromptFromFile(const QString &filePath)
{
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        setCurrentPrompt(in.readAll());
    } else {
        emit errorOccurred("Could not open file: " + filePath);
    }
}

void PromptManager::savePromptToFile(const QString &filePath)
{
    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << m_simplifiedPrompt;
    } else {
        emit errorOccurred("Could not save file: " + filePath);
    }
}
