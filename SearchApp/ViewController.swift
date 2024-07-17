//
//  ViewController.swift
//  SearchApp
//
//  Created by 김동율 on 7/17/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    
    // 자음 데이터
    let hangul = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
    // 서버에서 내려주는 데이터
    let serverArr = ["사과", "사과일까?", "과수일까?", "귤", "포도", "복숭아", "참외", "Apple", "Orange", "Grape", "Peach", "WaterMelon"]
    // 서버에서 온 데이터 담는 배열
    var localArr = [String]()
    // 선택된 배열
    var selectedArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        searchTf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        localArr = serverArr
        selectedArr = localArr
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }
    
    private func setupTableView() {
        searchTableView.register(UINib(nibName: "SearchCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "searchcell")
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    
    func isChosung(word: String) -> Bool {
        // 초성인지 아닌지 Flag
        var isChosung = false
        for char in word {
            // 검색하는 문자열전체가 초성인지 확인하기
            // 순회하면서 포함되어 있으면서 새로운 배열 ㄱㄱ
            if 0 < hangul.filter({ $0.contains(char)}).count {
                isChosung = true
            } else {
                // 초성이 아닌 문자섞이면 false 끝.
                isChosung = false
                break
            }
        }
        return isChosung
    }

    // 구글링해서 가져온건데 하... 복잡하다. 그냥 문자열에서 자음이 들어있는지 체크 하는 함수?
    func chosungCheck(word: String) -> String {
        var result = ""
        /*
         참고 : https://hongssup.tistory.com/130
         유니코드에서 한글 분리
         
         유니코드에서 한글은 0xAC00에서 0xD7A3 사이의 코드 값을 갖는다. 각 16진수 값은 10진수로 표시하면 44032와 55203으로 총 11,172개. 유니코드 내 한글은 초/중/종성의 조합으로 표현되며, 초성 19개, 중성 21개, 종성 28개를 조합하여 하나의 글자가 된다.
         초성 = ((문자코드 - 0xAC00) / 28) / 21
         중성 = ((문자코드 - 0xAC00) / 28 % 21
         종성 = (문자코드 - 0xAC00) % 28
         */
        
        /*
         부하예상되는 부분으로 초성 검색해야하는 (갯수 * 각 글자수) 만큼 for 문이 진행될텐데
         몇개 없을때는 괜찮겠지만, 1000개, 10000개 되었을때 이슈가 생기지 않을까..?
         애플 주소록도 첫번째 문자가 초성일때만 초성검색 하고 두개이상일때는 초성검색 하고 있지 않음.
         띄어쓰기 이슈, 특수문자 이슈 (한글유니코드값 범위 예외 추가함)
         */
        
        // 문자열하나씩 짤라서 확인
        for char in word {
            let octal = char.unicodeScalars[char.unicodeScalars.startIndex].value
            if 44032...55203 ~= octal { // 유니코드가 한글값 일때만 분리작업
                let index = (octal - 0xac00) / 28 / 21
                result = result + hangul[Int(index)]
            }
        }
        
        return result
    }
    
    // delegate에서 할려고 하다가 DidChange가 맞는거 같아서 이걸로 함.
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            selectedArr = localArr
            searchTableView.reloadData()
            
            return
        }
        
        guard let text = textField.text else { return }
        
        let isChosungCheck = isChosung(word: text)
        
        let filter = localArr.filter ({
            if isChosungCheck {
               return ($0.contains(text) || chosungCheck(word: $0).contains(text))
            } else {
               return $0.contains(text)
            }
        })
        
        if filter.isEmpty {
            selectedArr = ["찾는 검색어가 없습니다."]
            searchTableView.isUserInteractionEnabled = false
        } else {
            searchTableView.isUserInteractionEnabled = true
            selectedArr = filter
        }
        
        searchTableView.reloadData()
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return selectedArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchCell
        cell.titleLabel.text = selectedArr[indexPath.row]

        return cell
    }
}

