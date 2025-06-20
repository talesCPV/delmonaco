/* CLIENTES */

function buscaCli(cnpj=''){
   
    const data = new URLSearchParams()
        data.append("cnpj", cnpj)

    const myRequest = new Request("backend/asaas/buscaCliente.php",{
        method : "POST",
        body : data
    }) 

    return fetch(myRequest)
}

function newCli(body){
    const data = new URLSearchParams()
        data.append("body", JSON.stringify(body))

    const myRequest = new Request("backend/asaas/novoCliente.php",{
        method : "POST",
        body : data
    })    
    
    return fetch(myRequest)
}

function edtCli(cust,body){
    const data = new URLSearchParams()
        data.append("body", JSON.stringify(body))
        data.append("cust", cust.id)

    const myRequest = new Request("backend/asaas/edtCliente.php",{
        method : "POST",
        body : data
    })    
    
    return fetch(myRequest)
}

function delAsaasCust(asaas_id){
    const data = new URLSearchParams()
        data.append("cust", asaas_id)
    const myRequest = new Request("backend/asaas/delCliente.php",{
        method : "POST",
        body : data
    })
    return fetch(myRequest)
}

function delCli(cust){
    if(confirm('Deseja deletar este Cliente?')){
        return delAsaasCust(cust)
    }
}

/* CONTA CORRENTE */

function extrato(){
    const myRequest = new Request("backend/asaas/extrato.php",{
        method : "POST"
    }) 

    return fetch(myRequest)

}

/* COBRANÇAS */

function buscaCob(asaas_id=''){
    const data = new URLSearchParams()
        data.append("asaas_id", asaas_id)

    const myRequest = new Request("backend/asaas/buscaCobranca.php",{
        method : "POST",
        body : data
    }) 

    return fetch(myRequest)
}

function newCob(body){
    const data = new URLSearchParams()
        data.append("body", JSON.stringify(body))

    const myRequest = new Request("backend/asaas/novaCobranca.php",{
        method : "POST",
        body : data
    })    
    
    return fetch(myRequest)
}

function addCred(asaas_id,valor){
    const data = new URLSearchParams()
        data.append("asaas_id", asaas_id)
        data.append("value", valor)

    const myRequest = new Request("backend/asaas/addCredito.php",{
        method : "POST",
        body : data
    })    
    
    return fetch(myRequest)
}