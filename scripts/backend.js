/*  DATABASE  */
function queryDB(params,cod){
    let access = -1
    try{
        access = main_data.dashboard.data.access
    }catch{
        access = -1
    }

    const hash = localStorage.getItem('hash') == undefined ? 0 : localStorage.getItem('hash')
    const data = new URLSearchParams()
        data.append("access", access)
        data.append("hash", hash)
        data.append("cod", cod)
        data.append("params", JSON.stringify(params))

    const myRequest = new Request("backend/query_db.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text())        
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));
            } 
        });
    });      
}


function backFunc(params,cod){
    const data = new URLSearchParams();        
        data.append("cod", cod);
        data.append("params", JSON.stringify(params));        

    const myRequest = new Request("backend/functions.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    });      
}

function downloadFile(url, filename) {
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function getConfig(field){
    const data = new URLSearchParams();        
        data.append("user", localStorage.getItem('id_user'));
        data.append("field", field);
        data.append("file",'config.json');
    const myRequest = new Request("backend/getConfig.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function setConfig(field,value){
    const data = new URLSearchParams();        
    data.append("user", localStorage.getItem('id_user'));
    data.append("field", field);
    data.append("file",'config.json');
    data.append("value", value);
    const myRequest = new Request("backend/setConfig.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function uploadImage(fileID,path,filename){

    const up_data = new FormData();        
        up_data.append("up_file",  document.getElementById(fileID).files[0]);
        up_data.append("path", path);
        up_data.append("filename", filename);

    const myRequest = new Request("backend/upload.php",{
        method : "POST",
        body : up_data
    });

    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());             
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 

    return myPromisse
}

async function listFiles(path,ext='txt'){

    const data = new URLSearchParams()
        data.append("dir",path)
        data.append("ext",ext)
    const myRequest = new Request("backend/show_dir.php",{
        method : "POST",
        body : data
    })
    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {
                resolve(response.text())
            } else {
                reject(new Error("Houve algum erro na comunicação com o servidor"))
            }
        })
    })
    return await myPromisse.then((txt))
}

function getFile(path){
    const data = new URLSearchParams();        
        data.append("path", path);
    const myRequest = new Request("backend/loadFile.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function getTxt(path){
    const data = new URLSearchParams();        
        data.append("path", path);
    const myRequest = new Request("backend/loadTxt.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function delFile(path){
    const data = new URLSearchParams();        
        data.append("path", path);
    const myRequest = new Request("backend/delFile.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function NFeConf(file){
    file = JSON.stringify(file)
    saveFile(file,path='/../../NF/NFe/json/NFe.json')
}

function NFsConf(file){
    saveFile(file,path='/../../NF/NFe/json/NFs.json')
}

function saveFile(file,path){
    const data = new URLSearchParams();
        data.append("file", JSON.stringify(file));
        data.append("path", path);

    const myRequest = new Request("backend/saveFile.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 

}

function uploadNFe(txt, filename){

    saveFile(txt,path=`/../../NF/NFe/txt/${filename}.txt`).then(()=>{
        alert('NFe exportada com sucesso!!')
        listNF('../NF/NFe/txt')
        if (confirm(`Deseja lançar od boletos?`)) {
            const data = main_data.fisc_nfe.data.config
            for(let i=0; i<data.Y07.length; i++){
                const pgto = new Object            
                pgto.sac = data.E.xNome.split(' ')[0]
                pgto.nf = data.B.nNF
                pgto.ref =  (i+1).toString().padStart(2,"0") +'/'+ (data.Y07.length).toString().padStart(2,"0")
                pgto.venc = data.Y07[i].Y07.date
                pgto.val = data.Y07[i].Y07.valor
                addBoleto(pgto)
            }
        }
        document.querySelector('#tab-export').click()
    })    
}

function uploadNFs(txt, filename){

    saveFile(txt,path=`/../../NF/NFs/txt/${filename}.txt`).then(()=>{
        alert('NFs exportada com sucesso!!')
        listNF('../NF/NFs/txt')
        if (confirm(`Deseja lançar od boletos?`)) {
/*
            for(let i=0; i<pageData.NFs.fatura.length; i++){
                addBoleto(pageData.NFs.fatura[i])
            }
*/
        }
        document.querySelector('#tab-export').click()
    })
}

function uploadFile(file,path,filename){

    const up_data = new FormData()
    up_data.append("up_file",  file);
    up_data.append("path", path);
    up_data.append("filename", filename);

    const myRequest = new Request("backend/upload.php",{
        method : "POST",
        body : up_data
    })

    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());             
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"))
            } 
        });
    }); 

    return myPromisse
}

/* ENVIO DE EMAIL */
function sendMail(para,assunto,mensagem){
    //    addContact(message)
        const data = new URLSearchParams()
            data.append("para", para)
            data.append("assunto", assunto)
            data.append("mensagem", mensagem)
    
        const myRequest = new Request("backend/mail_pnt3.php",{
            method : "POST",
            body : data
        });
    
        return new Promise((resolve,reject) =>{
            fetch(myRequest)
            .then(function (response){
                if (response.status === 200) { 
                    resolve(response.text())
//                    alert('Mensagem enviada com sucesso!!! Obrigado pelo contato, aguarde que retornaremos o mais breve possível.')
                } else { 
                    reject(new Error("Houve algum erro na comunicação com o servidor"));
                } 
            });
        }); 
    }

    function confirmaUser(email,asaas_id){
        const url = 'https://planet3.com.br/backhand/backend/confirmEmail.php?asaas_id='+asaas_id
        const mail = `
            <style>
                body{
                    display: flex;
                    flex-direction: column;
                }

                .head, .middle{
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                }

                .button{
                    padding: 15px;
                    background-color: #84ecb2;
                    border: solid 1px;
                    border-radius: 10px;
                    text-decoration: none
                }

                .button:hover{
                    background-color: #519972;
                    color: aliceblue;
                }

            </style>


            <div class="head">
                <h2>Seja muito bem vindo ao BACKHAND</h2>
                <h4>o maior portal gerenciador de aulas de tênis do Brasil</h4>    
            </div>

            <div class="middle">
                <p>Clique no botão abaixo para finalizar seu cadastro e ganhe 3 meses grátis em nossa plataforma</p>

                <a href="${url}" class="button">CONFIRMAR CADASTRO</a>
            </div>`

        sendMail(email,'BACKHAND - Confirmação de Cadastro',mail)

    }

    function resetaPass(email,asaas_id){

        

        const url = 'https://planet3.com.br/backhand/backend/confirmEmail.php?asaas_id='+asaas_id
        const mail = `
            <style>
                body{
                    display: flex;
                    flex-direction: column;
                }

                .head, .middle{
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                }

                .button{
                    padding: 15px;
                    background-color: #84ecb2;
                    border: solid 1px;
                    border-radius: 10px;
                    text-decoration: none
                }

                .button:hover{
                    background-color: #519972;
                    color: aliceblue;
                }

            </style>


            <div class="head">
                <h2>Seja muito bem vindo ao BACKHAND</h2>
                <h4>o maior portal gerenciador de aulas de tênis do Brasil</h4>    
            </div>

            <div class="middle">
                <p>Clique no botão abaixo para finalizar seu cadastro e ganhe 3 meses grátis em nossa plataforma</p>

                <a href="${url}" class="button">CONFIRMAR CADASTRO</a>
            </div>`

        sendMail(email,'BACKHAND - Confirmação de Cadastro',mail)

    }