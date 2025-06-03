#include "projectcomparator.h"
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QTextStream>
#include <QProcess>
#include <QRegularExpression>

ProjectComparator::ProjectComparator(QObject *parent)
    : QObject(parent)
{
}

QString ProjectComparator::comparisonResult() const
{
    return m_comparisonResult;
}

void ProjectComparator::compareProjects(const QString &project1Path, const QString &project2Path)
{
    QDir dir1(project1Path);
    QDir dir2(project2Path);
    
    if (!dir1.exists() || !dir2.exists()) {
        emit errorOccurred("One or both project directories do not exist.");
        return;
    }
    
    QStringList files1 = getProjectFiles(project1Path);
    QStringList files2 = getProjectFiles(project2Path);
    
    QString result = "Project Comparison Results:\n\n";
    result += QString("Project 1: %1 (%2 files)\n").arg(project1Path).arg(files1.size());
    result += QString("Project 2: %1 (%2 files)\n\n").arg(project2Path).arg(files2.size());
    
    QStringList commonFiles;
    for (const QString &file1 : files1) {
        QString relativePath = QDir(project1Path).relativeFilePath(file1);
        QString file2 = project2Path + "/" + relativePath;
        if (QFile::exists(file2)) {
            commonFiles << relativePath;
            QString diff = compareFiles(file1, file2);
            if (!diff.isEmpty()) {
                result += QString("Differences in %1:\n%2\n\n").arg(relativePath, diff);
            }
        }
    }
    
    result += "Files only in Project 1:\n";
    for (const QString &file1 : files1) {
        QString relativePath = QDir(project1Path).relativeFilePath(file1);
        if (!commonFiles.contains(relativePath)) {
            result += "  " + relativePath + "\n";
        }
    }
    
    result += "\nFiles only in Project 2:\n";
    for (const QString &file2 : files2) {
        QString relativePath = QDir(project2Path).relativeFilePath(file2);
        if (!commonFiles.contains(relativePath)) {
            result += "  " + relativePath + "\n";
        }
    }
    
    m_comparisonResult = result;
    emit comparisonResultChanged();
}

QStringList ProjectComparator::getProjectFiles(const QString &projectPath)
{
    QStringList files;
    QDir dir(projectPath);
    
    QStringList nameFilters;
    nameFilters << "*.cpp" << "*.h" << "*.qml" << "*.js" << "*.py" << "*.java" 
                << "*.cs" << "*.php" << "*.rb" << "*.go" << "*.rs" << "*.swift"
                << "*.kt" << "*.scala" << "*.ts" << "*.jsx" << "*.tsx"
                << "*.pro" << "*.pri" << "*.cmake" << "CMakeLists.txt"
                << "*.json" << "*.xml" << "*.yaml" << "*.yml"
                << "Makefile" << "*.mk" << "*.gradle";
    
    QDirIterator it(projectPath, nameFilters, QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        files << it.next();
    }
    
    return files;
}

QString ProjectComparator::compareFiles(const QString &file1, const QString &file2)
{
    QProcess process;
    QStringList arguments;
    arguments << "-u" << file1 << file2;
    
    process.start("diff", arguments);
    process.waitForFinished();
    
    QString diff = process.readAllStandardOutput();
    return generateDiffSummary(diff);
}

QString ProjectComparator::generateDiffSummary(const QString &diff)
{
    if (diff.isEmpty()) {
        return QString();
    }
    
    QStringList lines = diff.split('\n');
    QString summary;
    int addedLines = 0;
    int removedLines = 0;
    
    for (const QString &line : lines) {
        if (line.startsWith('+') && !line.startsWith("+++")) {
            addedLines++;
        } else if (line.startsWith('-') && !line.startsWith("---")) {
            removedLines++;
        }
    }
    
    summary = QString("  +%1 -%2 lines changed\n").arg(addedLines).arg(removedLines);
    
    int changeCount = 0;
    for (const QString &line : lines) {
        if ((line.startsWith('+') || line.startsWith('-')) && 
            !line.startsWith("+++") && !line.startsWith("---") && 
            changeCount < 3) {
            summary += "    " + line + "\n";
            changeCount++;
        }
    }
    
    if (lines.size() > changeCount + 4) {
        summary += "    ... (more changes)\n";
    }
    
    return summary;
}

void ProjectComparator::generateComparisonPrompt()
{
    if (m_comparisonResult.isEmpty()) {
        emit errorOccurred("No comparison result available. Please compare projects first.");
        return;
    }
    
    QString prompt = "Analyze the following project comparison and provide insights:\n\n";
    prompt += m_comparisonResult;
    prompt += "\n\nPlease provide:\n";
    prompt += "1. Summary of key differences\n";
    prompt += "2. Potential compatibility issues\n";
    prompt += "3. Recommendations for merging or synchronizing\n";
    prompt += "4. Code quality observations\n";
    
    emit comparisonPromptGenerated(prompt);
}
