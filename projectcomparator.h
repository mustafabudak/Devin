#ifndef PROJECTCOMPARATOR_H
#define PROJECTCOMPARATOR_H

#include <QObject>
#include <QString>
#include <QStringList>

class ProjectComparator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString comparisonResult READ comparisonResult NOTIFY comparisonResultChanged)

public:
    explicit ProjectComparator(QObject *parent = nullptr);

    QString comparisonResult() const;

    Q_INVOKABLE void compareProjects(const QString &project1Path, const QString &project2Path);
    Q_INVOKABLE void generateComparisonPrompt();

signals:
    void comparisonResultChanged();
    void comparisonPromptGenerated(const QString &prompt);
    void errorOccurred(const QString &error);

private:
    QString m_comparisonResult;
    
    QStringList getProjectFiles(const QString &projectPath);
    QString compareFiles(const QString &file1, const QString &file2);
    QString generateDiffSummary(const QString &diff);
};

#endif // PROJECTCOMPARATOR_H
