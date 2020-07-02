@Library("shared-libraries")
import libs.ProjectHelpers
import libs.Utils

def utils = new Utils()
def projectHelpers = new ProjectHelpers()
def kickUsersTasks = [:]
def lockIBTasks = [:]
def backupConfTasks = [:]
def backupIbTasks = [:]
def prepareUpdateTasks = [:]
def updateIBTasks = [:]
def unlockIBTasks = [:]

pipeline {
    parameters {
        string(defaultValue: "${env.jenkinsAgent}", description: 'Нода дженкинса, на которой запускать пайплайн. По умолчанию master', name: 'jenkinsAgent')
        string(defaultValue: "${env.platform1c}", description: 'Версия платформы 1с, например 8.3.14.1694. По умолчанию будет использована последня версия среди установленных', name: 'platform1c')
        string(defaultValue: "${env.server1c}", description: 'Имя сервера 1с, по умолчанию localhost', name: 'server1c')
        string(defaultValue: "${env.port1c}", description: 'Порт сервера 1с. По умолчанию 1540. Не путать с портом агента кластера (1541)', name: 'port1c')
        string(defaultValue: "${env.infobases}", description: 'Список баз для обновления через запятую. Например c83_ack,c83_ato', name: 'infobases')
        string(defaultValue: "${env.user}", description: 'Имя администратора базы 1с Должен быть одинаковым для всех баз', name: 'user')
        string(defaultValue: "${env.passw}", description: 'Пароль администратора базы 1C. Должен быть одинаковым для всех баз', name: 'passw')
        string(defaultValue: "${env.backupDir}", description: 'Путь для сохранения бэкапов 1c', name: 'backupDir')
        string(defaultValue: "${env.repServer1c}", description: 'Имя сервера 1с базы, подключенной к хранилищу, по умолчанию localhost', name: 'repServer1c')
        string(defaultValue: "${env.repInfobase}", description: 'База подключенная к хранилищу', name: 'repInfobase')
        string(defaultValue: "${env.repPath}", description: 'Необязательный. Пути к хранилищам 1С для обновления копий баз тестирования через запятую. Число хранилищ (если указаны), должно соответствовать числу баз тестирования. Например D:/temp/storage1c/ack,D:/temp/storage1c/ato', name: 'repPath')
        string(defaultValue: "${env.repUser}", description: 'Необязательный. Администратор хранилищ  1C. Должен быть одинаковым для всех хранилищ', name: 'repUser')
        string(defaultValue: "${env.repPassw}", description: 'Необязательный. Пароль администратора хранилищ 1c', name: 'repPassw')
        string(defaultValue: "${env.permCode}", description: 'Необязательный. Код блокировки ИБ при обновлениию. По умолчанию 0000', name: 'permCode')
    }
    agent {
        label "${(env.jenkinsAgent == null || env.jenkinsAgent == 'null') ? "master" : env.jenkinsAgent}"
    }
    options {
        timeout(time: 8, unit: 'HOURS') 
        buildDiscarder(logRotator(numToKeepStr:'10'))
    }
    stages {
        stage("Подготовка") {
            steps {
                timestamps {
                    script {
                        infobasesList = utils.lineToArray(infobases.toLowerCase())
                        repPathList = utils.lineToArray(repPath.toLowerCase())
                        if (repPathList.size() != 0) {
                            assert repPathList.size() == infobasesList.size()
                        }
                        platform1c = "C:\\Program Files (x86)\\1cv8\\" + (platform1c.isEmpty() ? "common\\1cestart.exe" : (platform1c + "\\bin\\1cv8.exe"))
                        server1c = server1c.isEmpty() ? 'localhost' : server1c
                        repServer1c = repServer1c.isEmpty() ? 'localhost' : repServer1c
                        port1c = port1c.isEmpty() ? '1540' : port1c
                        repPassw = repPassw.isEmpty() ? 'default' : repPassw
                        permCode = permCode.isEmpty() ? '0000' : permCode
                    }
                }
            }
        }
        stage("Запуск") {
            steps {
                timestamps {
                    script {
                        for (i = 0;  i < infobasesList.size(); i++) {
                            infobase = infobasesList[i]
                            // 1. Блокирум запуск соединений и РЗ
                            lockIBTasks["lockIBTask_${infobase}"] = lockIBTask(server1c, port1c, infobase, user, passw, 'lock', permCode)
                            // 2. Выбрасываем пользователей из базы 1С
                            kickUsersTasks["kickUsersTask_${infobase}"] = kickUsersTask(server1c, port1c, infobase, user, passw)
                            // 3. Создаём бэкап конфигурации
                            backupConfTasks["backupConfTask_${infobase}"] = backupConfTask(platform1c, server1c, infobase, user, passw, backupDir, permCode)
                            // 4. Создаём бэкап ИБ
                            backupIbTasks["backupIbTask_${infobase}"] = backupIbTask(platform1c, server1c, infobase, user, passw, backupDir, permCode)
                            // 5. Создаем файл обновления
                            prepareUpdateTasks["prepareUpdateTask_${infobase}"] = prepareUpdateTask(platform1c, repServer1c, repInfobase, repUser, repPassw, repPath, user, passw, backupDir, permCode)
                            // 6. Обновляем ИБ
                            updateIBTasks["updateIBTask_${infobase}"] = updateIBTask(platform1c, server1c, infobase, user, passw, backupDir, permCode)
                            // 7. Разблокирум запуск соединений и РЗ
                            unlockIBTasks["unlockIBTask_${infobase}"] = lockIBTask(server1c, port1c, infobase, user, passw, 'unlock', permCode)
                        }
                        parallel lockIBTasks
                        parallel kickUsersTasks
                        parallel backupConfTasks
                        parallel backupIbTasks
                        parallel prepareUpdateTasks
                        parallel updateIBTasks
                        parallel unlockIBTasks
                    }
                }
            }
        }
    }
   post {
        always {
            emailext body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']],
                subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}"
        }
    }
}

def lockIBTask(server1c, port1c, infobase, user, passw, action, permCode) {
    return {
        stage("Изменение разрешения на запуск РЗ в ${infobase}: ${action}") {
            timestamps {
                def projectHelpers = new ProjectHelpers()
                projectHelpers.lockIBTask(server1c, port1c, infobase, user, passw, action, permCode)
            }
        }
    }
}

def kickUsersTask(server1c, port1c, infobase, user, passw) {
    return {
        stage("Выбрасывание пользователей из 1С ${infobase}") {
            timestamps {
                def projectHelpers = new ProjectHelpers()
                projectHelpers.kickUsers(server1c, port1c, infobase, user, passw)
            }
        }
    }
}

def backupConfTask(platform1c, server1c, infobase, user, passw, backupDir, permCode) {
    return {
        stage("Сохранение конфигурации базы ${infobase}") {
            timestamps {
                def projectHelpers = new ProjectHelpers()
                projectHelpers.backupConf(platform1c, server1c, infobase, user, passw, backupDir, permCode)
            }
        }
    }
}

def backupIbTask(platform1c, server1c, infobase, user, passw, backupDir, permCode) {
    return {
        stage("Создание выгрузки информационной базы ${infobase}") {
            timestamps {
                def projectHelpers = new ProjectHelpers()
                projectHelpers.backupIb(platform1c, server1c, infobase, user, passw, backupDir, permCode)
            }
        }
    }
}

def prepareUpdateTask(platform1c, repServer1c, repInfobase, repUser, repPassw, repPath, user, passw, backupDir, permCode) {
    return {
        stage("Подготовка файла обновления информационной базы ${infobase}") {
            timestamps {
                def projectHelpers = new ProjectHelpers()
                projectHelpers.prepareUpdate(platform1c, repServer1c, repInfobase, repUser, repPassw, repPath, user, passw, backupDir, permCode)
            }
        }
    }
}

def updateIBTask(platform1c, server1c, infobase, user, passw, backupDir, permCode) {
    return {
        stage("Обновление информационной базы ${infobase}") {
            timestamps {
                def projectHelpers = new ProjectHelpers()
                projectHelpers.update(platform1c, server1c, infobase, user, passw, backupDir, permCode)
            }
        }
    }
}