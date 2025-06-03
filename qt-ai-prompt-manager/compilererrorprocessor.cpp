#include "compilererrorprocessor.h"
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>

CompilerErrorProcessor::CompilerErrorProcessor(QObject *parent)
    : QObject(parent)
{
}

QString CompilerErrorProcessor::errorText() const
{
    return m_errorText;
}

void CompilerErrorProcessor::setErrorText(const QString &text)
{
    if (m_errorText != text) {
        m_errorText = text;
        emit errorTextChanged();
    }
}

QString CompilerErrorProcessor::processedPrompt() const
{
    return m_processedPrompt;
}

void CompilerErrorProcessor::processErrors()
{
    if (m_errorText.isEmpty()) {
        emit errorOccurred("No error text to process.");
        return;
    }
    
    QList<CompilerError> errors = parseErrors(m_errorText);
    m_processedPrompt = formatErrorsForAI(errors);
    emit processedPromptChanged();
}

void CompilerErrorProcessor::loadErrorsFromFile(const QString &filePath)
{
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        setErrorText(in.readAll());
    } else {
        emit errorOccurred("Could not open file: " + filePath);
    }
}

QList<CompilerErrorProcessor::CompilerError> CompilerErrorProcessor::parseErrors(const QString &errorText)
{
    QList<CompilerError> errors;
    QStringList lines = errorText.split('\n');
    
    for (const QString &line : lines) {
        if (line.trimmed().isEmpty()) continue;
        
        CompilerError error;
        
        if (line.contains(":") && (line.contains("error") || line.contains("warning"))) {
            error = parseGccError(line);
        } else if (line.contains("(") && line.contains(")") && line.contains(":")) {
            error = parseMsvcError(line);
        }
        
        if (!error.message.isEmpty()) {
            errors.append(error);
        }
    }
    
    return errors;
}

CompilerErrorProcessor::CompilerError CompilerErrorProcessor::parseGccError(const QString &errorLine)
{
    CompilerError error;
    
    QRegularExpression re(R"(^(.+?):(\d+):(?:\d+:)?\s*(error|warning):\s*(.+)$)");
    QRegularExpressionMatch match = re.match(errorLine);
    
    if (match.hasMatch()) {
        error.file = match.captured(1);
        error.line = match.captured(2).toInt();
        error.type = match.captured(3);
        error.message = match.captured(4);
    }
    
    return error;
}

CompilerErrorProcessor::CompilerError CompilerErrorProcessor::parseMsvcError(const QString &errorLine)
{
    CompilerError error;
    
    QRegularExpression re(R"(^(.+?)\((\d+)\):\s*(error|warning)\s+C\d+:\s*(.+)$)");
    QRegularExpressionMatch match = re.match(errorLine);
    
    if (match.hasMatch()) {
        error.file = match.captured(1);
        error.line = match.captured(2).toInt();
        error.type = match.captured(3);
        error.message = match.captured(4);
    }
    
    return error;
}

CompilerErrorProcessor::CompilerError CompilerErrorProcessor::parseClangError(const QString &errorLine)
{
    return parseGccError(errorLine); // Clang uses similar format to GCC
}

QString CompilerErrorProcessor::formatErrorsForAI(const QList<CompilerError> &errors)
{
    if (errors.isEmpty()) {
        return "No compiler errors found in the provided text.";
    }
    
    QString prompt = "Fix the following compiler errors:\n\n";
    
    QMap<QString, QList<CompilerError>> errorsByFile;
    for (const CompilerError &error : errors) {
        errorsByFile[error.file].append(error);
    }
    
    for (auto it = errorsByFile.begin(); it != errorsByFile.end(); ++it) {
        const QString &file = it.key();
        const QList<CompilerError> &fileErrors = it.value();
        
        prompt += QString("File: %1\n").arg(file);
        
        for (const CompilerError &error : fileErrors) {
            prompt += QString("  Line %1 [%2]: %3\n")
                     .arg(error.line)
                     .arg(error.type.toUpper())
                     .arg(error.message);
        }
        prompt += "\n";
    }
    
    prompt += "Please provide:\n";
    prompt += "1. Root cause analysis for each error\n";
    prompt += "2. Specific code fixes with line numbers\n";
    prompt += "3. Explanation of the fixes\n";
    prompt += "4. Prevention strategies for similar errors\n";
    
    return prompt;
}

void CompilerErrorProcessor::generateFixPrompt()
{
    processErrors();
    if (!m_processedPrompt.isEmpty()) {
        emit promptGenerated(m_processedPrompt);
    }
}
