import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'auto.yourname'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    Page {
        id: mainPage
        anchors.fill: parent
        title: "Auto Reminder"

        Column {
            anchors.centerIn: parent
            spacing: units.gu(2)
            width: units.gu(40)

            // Поле для ввода пробега
            TextField {
                id: inputField
                placeholderText: "Введите пробег"
                inputMethodHints: Qt.ImhDigitsOnly
                width: parent.width
                font.pixelSize: units.gu(2.5)
                horizontalAlignment: TextField.AlignHCenter
            }

            // Поле для вывода текста (ошибки или сообщения)
            Label {
                id: outputLabel
                text: "Введите пробег и нажмите кнопку."
                horizontalAlignment: Label.AlignHCenter
                wrapMode: Text.Wrap
                width: parent.width
                height: implicitHeight
                maximumLineCount: 10
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: units.gu(2)
            }

            // Кнопка для отправки данных
            Button {
                text: "Список ТО"
                onClicked: {
                    let value = inputField.text.trim();
                    console.log('value:', value);

                    if (value === "") {
                        outputLabel.text = "Поле ввода не может быть пустым";
                    } else {
                        python.call("main.set_mileage", [value], function(result) {

                            try {
                                // Преобразуем в строку, если это не строка
                                let jsonString = typeof result === "string" ? result : String(result);

                                // Проверяем, содержит ли строка невалидные символы
                                jsonString = jsonString.replace(/[^\x20-\x7E\u0400-\u04FF]/g, ""); // Убираем нелатинские символы (кроме кириллицы)

                                console.log("cleaned jsonString:", jsonString);

                                // Пробуем распарсить JSON
                                let data = JSON.parse(jsonString);

                                if (!Array.isArray(data)) {
                                    throw new Error("Ожидался массив, получено: " + typeof data);
                                }

                                partsModel.clear(); // Очищаем модель перед добавлением новых данных

                                for (let part of data) {
                                    console.log('part:', part);
                                    if (part.hasOwnProperty('part_name') && part.hasOwnProperty('part_id')) {
                                        partsModel.append({
                                            partId: part.part_id,
                                            partName: part.part_name,
                                            partPrice: part.price

                                        });
                                    } else {
                                        console.warn("Пропущен элемент без part_name или part_id:", part);
                                    }
                                }

                                outputLabel.text = "Пробег" + " " + value * 1000;
                            } catch (error) {
                                console.error("Ошибка обработки JSON:", error.message);
                                outputLabel.text = "Ошибка: неверный формат данных от сервера";
                            }
                        });
                    }
                }
            }

            ListModel {
                id: partsModel
            }

            // Список для отображения запчастей
            ListView {
                id: partsList
                width: parent.width
                height: units.gu(20)
                model: partsModel
                delegate: Item {
                    width: parent.width
                    height: units.gu(5)

                    Row {
                        spacing: units.gu(2)
                        anchors.centerIn: parent

                        // ID запчасти
                        Label {
                            text: model.partId
                            font.pixelSize: units.gu(2)
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Название запчасти
                        Label {
                            text: model.partName
                            font.pixelSize: units.gu(2)
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Цена
                        Label {
                            text: model.partPrice
                            font.pixelSize: units.gu(2)
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

        }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importModule('main', function() {
                console.log('module imported');
            });
        }

        onError: {
            console.log('python error: ' + traceback);
            outputLabel.text = "Ошибка Python: " + traceback;
        }
    }
}
