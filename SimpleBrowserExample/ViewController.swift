//
//  ViewController.swift
//  SimpleBrowserExample
//
//  Created by AppDev on 19/04/18.
//  Copyright © 2018 Droal. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    var wkWebView : WKWebView!
    var progressView : UIProgressView!
    var websites = ["eltiempo", "apple", "bbc", "nasa.gov"]
    var websitesSec = ["http://www.", "http://www.", "http://www.", "https://www."]
    
    override func loadView() {
        wkWebView = WKWebView()
        wkWebView.navigationDelegate = self
        view = wkWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //cargar una pagina inicial
        let urlTarget = URL(string: "https://www.nasa.gov/")!
        wkWebView.load(URLRequest(url: urlTarget))
        
        //habilita la propiedad para moverse atras y adelante, en el navegador, con el gesto de swipe
        wkWebView.allowsBackForwardNavigationGestures = true
        
        
        //UIToolbar contiene un array de objetos: "UIBarButtonItem", por ejemplo el "rigthBarButton"
        //Todos los view controller contienen un conjunto de toolbarItems los cuales son cargados cuando el view controller se encuentra activo
        
        //Se crean dos UIBarButtonItems
        //El primer parametro es el tipo de boton, en este caaso: "flexibleSpace", es un elemento que actua como un resorte empujando otros botones hacia un lado hasta que se usa todo el espacio disponible
        //Este elemento no genera ninguna accion por lo tanto los demas parametros son nil
        let spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //El segundo botón es el botonde recarga de la pagina
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: wkWebView, action: #selector(wkWebView.reload))
        
        //UIProgressView es un indicador del progreso de una tarea
        //Para agregar la vista del indicador de progreso (UIProgressView) al toolbar este debe enmascararse dentro de un "UIBarButtonItem"
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        //se agregan los botones a la toolbar
        toolbarItems = [progressButton, spacerButton, refreshButton]
        //se hace visible la toolbar
        navigationController?.isToolbarHidden = false
        
        
        //Agregar un boton al navigation bar
        //El parametro "style" configura la apariencia del boton
        //El parametro "target", indica que el metodo que se va a ejecutar al seleccionar este elemento pertenece al ViewController actual
        //El parametro "action" indica el metodo que se debe ejecutar cuando se selecciona el boton
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sites", style: .plain, target: self, action: #selector(sitesButtonIsTapped))
        
        
        //WKNavigationDelegate no entrega informacion a cerca del proceso de carga de la pagina, por lo tanto es necesario implementar un key-value observing (KVO)
        //En aplicaciones complejas todas las llamadas a addObserver() deben tener un llamado a removeObserver() cuando termine la observacion
        
        //El primer parametro (observer:) indica quien será el observador
        //El segundo parametro (forKeyPath:) indica la propiedad a observar, #keyPath indica al compilador que verifique que el codigo entre parentesisi es correcto
        //El tercer parametro (options:) indica cual valor de la propiedad a observar queremos obtener
        //El cuarto parametro (context:) correspondde al contexto de la clase
        wkWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
    }

   
    //Metodo que se ejecuta cuando se selecciona el boton "Sites" de la barra de navegacion
    @objc func sitesButtonIsTapped(){
        
        //Crea un mensaje de alerta que contiene opciones para el usuario (actionSheet) no un mensaje
        let alertController = UIAlertController(title: "Pages you can open:", message: nil, preferredStyle: .actionSheet)
        
        //Se agregan las diferentes opciones de la alerta
        for site in websites{
            alertController.addAction(UIAlertAction(title: site, style: .default, handler: openPageSelected))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Ancla la ventana emergente al boton que genero la accion, esto solo tiene efecto en los iPad
        alertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        present(alertController, animated: true)
    }
    
    func openPageSelected(action: UIAlertAction){
        //URL es un tipo de dato usado por swift para almacenar las ubicaciones de archivos
        //Es mas reconocido por almacenar direciones web pero tambien se emplea para almacenar archivos locales
        //La url debe estar completa es decir debe incluir el "https://"
        //OJO: Cuando la url No es "https" se debe modificar el archivo Info.plist para configurar : <key>NSAppTransportSecurity</key> y permitir la carga de sitios "http"
        let urlTarget = URL(string: "" + websitesSec[websites.index(of: action.title!)!] + action.title! + ".com")!
        wkWebView.load(URLRequest(url: urlTarget))
    }
    
    //Este es un metodo del WKNavigationDelegate
    //Este metodo actualiza el titulo del view controller para mostrar el nombre de la pagina web abierta
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    //Este es un metodo del WKNavigationDelegate
    //Este metodo permite decidir si queremos que lanavegacion suceda o no
    //Permite verificar: que partte de la pagina inicio la navegacion, ver si se activo al seleccionar un enlace o al enviar un formulario, verificar la URL
    //En este caso este metodo lo usamos para verificar si la url se encuentra en nuestra lista segura de lo coantrario no permitir la carga de la pagina
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
/*
        if let host = url?.host {
            if websites.contains(host){
               decisionHandler(.allow)
            }
            else{
               decisionHandler(.cancel)
            }
        }
        else{
            decisionHandler(.cancel)
        }
  */

        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }

        }
        
        decisionHandler(.cancel)
  
    }

    

    
    
    //Esta funcion se ejecta cuando el valor observado cambia
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            progressView.progress = Float(wkWebView.estimatedProgress)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        wkWebView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

