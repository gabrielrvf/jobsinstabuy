//
//  ViewController.swift
//  forinstabuy
//
//  Created by Gabriel Vilarouca on 19/01/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tamanha_logoCima: NSLayoutConstraint!
    
    //BANNER DE CIMA
    @IBOutlet weak var ef_banner: UIVisualEffectView!
    @IBOutlet weak var text_banner: UILabel!
    @IBOutlet weak var imagem_banner: UIImageView!
    @IBOutlet weak var page_control: UIPageControl!
    var imgs = [  #imageLiteral(resourceName: "cropped-logo-1.png") ]
    var timer = Timer()
    var valor_imgs = 0
    var valor_tempo = 0
    
    //Separando
    var nomes_produtos = [""]
    var valores_produtos = [0.0]
    
    //Tela de carregamento
    @IBOutlet weak var ef_carrega: UIVisualEffectView!
    @IBOutlet weak var larg_logo: NSLayoutConstraint!
    @IBOutlet weak var altura_logo: NSLayoutConstraint!
    @IBOutlet weak var logo_carrega: UIImageView!
    
    //Tabela de produtos
    @IBOutlet weak var tableView: UITableView!
    
    //OUTROS
    let selection = UISelectionFeedbackGenerator()
    let notification = UINotificationFeedbackGenerator()
    var continuar = false
    
    //Mostra produto
    @IBOutlet weak var efView: UIVisualEffectView!
    @IBOutlet weak var img_doview: UIImageView!
    @IBOutlet weak var txt_doview: UILabel!
    @IBOutlet weak var ef_doview: UIVisualEffectView!
    
    //EDITAVEIS
    var quantos_banners = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        page_control.numberOfPages = quantos_banners
        tableView.layer.borderWidth = 2
        tableView.layer.cornerRadius = 40
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        
        UIView.animate(withDuration: 4, animations: {
            self.larg_logo.constant = 300
            self.altura_logo.constant = 200
            self.logo_carrega.layoutIfNeeded()
        })
        
        chamar_valores()
        
    }
    
    func chamar_valores(){
        let url = URL(string: "https://api.instabuy.com.br/apiv3/item")!
        URLSession.shared.dataTask(with: url){ data, response, error in
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    
                    let data = json["data"] as! NSArray
                    var contador = data.count
                    self.imgs.removeAll()
                    self.nomes_produtos.removeAll()
                    self.valores_produtos.removeAll()
                    
                    while contador != 0 {
                        contador -= 1
                        //valor
                        let valores_data = data[contador] as! NSDictionary
                        let preco = valores_data["prices"] as! NSArray
                        let preco_valor = preco[0] as! NSDictionary
                        let preco_final = preco_valor["price"] as! Double
                        self.valores_produtos.append(preco_final)
                        //nome
                        let nome_do_produto = valores_data["name"] as! NSString
                        self.nomes_produtos.append(nome_do_produto as String)
                        //url_imagem
                        let imagem = valores_data["images"] as! NSArray
                        let url_complementoImagem = imagem[0] as! NSString
                        let url_completa = URL(string: "https://assets.instabuy.com.br/ib.item.image.big/b-\(url_complementoImagem)")
                        if let data = try? Data(contentsOf: url_completa!) {
                            self.imgs.append(UIImage(data: data)!)
                                //imageView.image = UIImage(data: data)
                        }
                    }
                    self.valor_imgs = self.quantos_banners
                    self.continuar = true
                    DispatchQueue.main.async {
                        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.mudarImagem), userInfo: nil, repeats: true)
                    }
                }
            } catch let error as NSError {
                print("Falha para carregar: \(error.localizedDescription)")
                self.notification.notificationOccurred(.error)
            }
        }.resume()
    }
    
    //Mostrar banner
    @objc func mudarImagem() {
        if continuar == true{
            tableView.reloadData()
            continuar = false
            notification.notificationOccurred(.success)
            UIView.animate(withDuration: 0.5, animations: {
                self.ef_carrega.alpha = 0
            })
        }
        chamar_elementos()
    }
    
    @IBAction func click_pagecontrol(_ sender: Any) {
        valor_tempo = page_control.currentPage
        chamar_elementos()
    }
    
    func chamar_elementos(){
        if valor_tempo != valor_imgs{
            page_control.currentPage = valor_tempo
            imagem_banner.image = imgs[valor_tempo]
            text_banner.text = "\(nomes_produtos[valor_tempo])\nR$ \(valores_produtos[valor_tempo])"
            valor_tempo += 1
        }else{
            valor_tempo = 0
            page_control.currentPage = valor_tempo
            imagem_banner.image = imgs[valor_tempo]
            text_banner.text = "\(nomes_produtos[valor_tempo])\nR$ \(valores_produtos[valor_tempo])"
        }
    }
    
    //TABELA
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection.selectionChanged()
        img_doview.image = imgs[indexPath.row]
        txt_doview.text = "\(nomes_produtos[indexPath.row])\nR$: \(valores_produtos[indexPath.row])"
        UIView.animate(withDuration: 1.5, animations: {
            self.efView.alpha = 1
            self.ef_doview.layer.borderWidth = 2
            self.ef_doview.layer.cornerRadius = 40
            self.ef_doview.clipsToBounds = true
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nomes_produtos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = "\(nomes_produtos[indexPath.row])\nR$: \(valores_produtos[indexPath.row])"
        cell?.layer.borderWidth = 1
        cell?.textLabel?.numberOfLines = 0
        let myColor = UIColor.black
        cell?.layer.borderColor = myColor.cgColor
        cell?.textLabel?.textColor = myColor
        cell?.textLabel?.font = UIFont(name:"System-Medium",size:25)
        cell?.backgroundColor = .clear
        cell?.contentView.backgroundColor = UIColor(white: 1, alpha: 0)
        cell?.imageView!.image = image(imgs[indexPath.row], withSize: CGSize(width: 70, height: 70))
        return cell!
    }
    
    func image( _ image:UIImage, withSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }
    
    //VISUALIZAR PRODUTO
    @IBAction func fechar_view(_ sender: Any) {
        fechar_aview()
    }
    
    @IBAction func sair_view(_ sender: Any) {
        fechar_aview()
    }
    
    func fechar_aview(){
        selection.selectionChanged()
        UIView.animate(withDuration: 1.5, animations: {
            self.efView.alpha = 0
            self.ef_doview.layer.borderWidth = 1
            self.ef_doview.layer.cornerRadius = 0
            self.ef_doview.clipsToBounds = true
        })
    }
    
    
}

