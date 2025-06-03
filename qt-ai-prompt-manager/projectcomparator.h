#ifndef PROJECTCOMPARATOR_H
#define PROJECTCOMPARATOR_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

class ProjectComparator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString comparisonResult READ comparisonResult NOTIFY comparisonResultChanged)
    Q_PROPERTY(QVariantList fileTree1 READ fileTree1 NOTIFY fileTree1Changed)
    Q_PROPERTY(QVariantList fileTree2 READ fileTree2 NOTIFY fileTree2Changed)
    Q_PROPERTY(QString currentFile1Content READ currentFile1Content NOTIFY currentFile1ContentChanged)
    Q_PROPERTY(QString currentFile2Content READ currentFile2Content NOTIFY currentFile2ContentChanged)
    Q_PROPERTY(QVariantList diffLines READ diffLines NOTIFY diffLinesChanged)

public:
    explicit ProjectComparator(QObject *parent = nullptr);

    QString comparisonResult() const;
    QVariantList fileTree1() const;
    QVariantList fileTree2() const;
    QString currentFile1Content() const;
    QString currentFile2Content() const;
    QVariantList diffLines() const;

    Q_INVOKABLE void compareProjects(const QString &project1Path, const QString &project2Path);
    Q_INVOKABLE void generateComparisonPrompt();
    Q_INVOKABLE void selectFile(const QString &relativePath);
    Q_INVOKABLE QString getFileContent(const QString &filePath);

signals:
    void comparisonResultChanged();
    void comparisonPromptGenerated(const QString &prompt);
    void errorOccurred(const QString &error);
    void fileTree1Changed();
    void fileTree2Changed();
    void currentFile1ContentChanged();
    void currentFile2ContentChanged();
    void diffLinesChanged();

private:
    QString m_comparisonResult;
    QString m_project1Path;
    QString m_project2Path;
    QVariantList m_fileTree1;
    QVariantList m_fileTree2;
    QString m_currentFile1Content;
    QString m_currentFile2Content;
    QVariantList m_diffLines;
    
    QStringList getProjectFiles(const QString &projectPath);
    QString compareFiles(const QString &file1, const QString &file2);
    QString generateDiffSummary(const QString &diff);
    QVariantList buildFileTree(const QString &projectPath);
    QVariantMap createFileNode(const QString &name, const QString &path, bool isDirectory);
    QVariantList generateLineDiff(const QString &content1, const QString &content2);
};

#endif // PROJECTCOMPARATOR_H
