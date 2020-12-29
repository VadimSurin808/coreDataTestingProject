//
//  MainViewController.swift
//  coreDataTestingProject
//
//  Created by Вадим Сурин on 29.12.2020.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    
    //MARK: -- Outlet's
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: -- Core Data
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var container: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchData()
    }
    
    //MARK: --Method's
    private func setup() {
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        let navItem = UINavigationItem(title: "Таблица")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: #selector(tapOnAddButton))
        navItem.rightBarButtonItem = doneItem

        navBar.setItems([navItem], animated: false)
    }
    
    private func fetchData() {
        do {
            container = try context.fetch(Person.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Ошибка при получении данных")
        }
    }
    
    @objc func tapOnAddButton() {
        let alert = UIAlertController(title: "Добавьте персонажа", message: "Пожалуйста, впишите персонажа", preferredStyle: UIAlertController.Style.alert )

        let save = UIAlertAction(title: "Сохранить", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                //Устанавливаем новые данные
                let newPerson = Person(context: self.context)
                newPerson.name = textField.text
                newPerson.age = 0
                newPerson.gender = ""
                //Сохраняем новые данные в core data
                do {
                    try self.context.save()
                } catch {
                    print("Ошибка сохранения")
                }
                //Получаем новые данные из core data
                self.fetchData()
                
            }
        }

        alert.addTextField { (textField) in
            textField.placeholder = "Ввести"
        }
        alert.addAction(save)
        
        let cancel = UIAlertAction(title: "Отменить", style: .default) { (alertAction) in }
        alert.addAction(cancel)

        self.present(alert, animated:true, completion: nil)
    }
}


extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return container?.count ?? 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        let person = container![indexPath.row]
        cell.textLabel?.text = person.name
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Удаление из таблички и из core data
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, completion) in
            guard let item = self.container else { return }
            let personToRemove = item[indexPath.row]
            
            self.context.delete(personToRemove)
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fetchData()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
