/*  IMPORTS  */




/*  VARIABLES  */

var doc = new jsPDF({
    orientation: 'p',
    unit: 'mm',
    format: 'a4'
}) 

var txt = new Object
    txt.lineHeigth = 5
    txt.x = 10
    txt.y = 10
    txt.page = 1
    txt.width = doc.internal.pageSize.getWidth() - txt.x
    txt.text
    txt.dim = [90,80] 

var imgData = new Image()
    imgData.src = 'assets/reports/head.png'

/* FUNCTIONS */

function addPage(Y=76){
    doc.addPage();
    plotImg('assets/reports/head.png',0,0,210)    
    txt.y = Y 
}

function addLine(N=1, botton=10, callback=0){
    txt.y += txt.lineHeigth * N
    if(txt.y >= doc.internal.pageSize.getHeight() - botton){
        callback ? callback() : addPage()
        return false
    }
    return true
}

function clearTxt(y=10,x=10,dim=[90,80]){
    txt = new Object
        txt.lineHeigth = 5
        txt.x = x
        txt.y = y
        txt.page = 1
        txt.width = doc.internal.pageSize.getWidth() - txt.x
        txt.text = ''
        txt.dim = dim 

}

function frame(margin=5){
    doc.rect(margin,margin,doc.internal.pageSize.getWidth()-margin*2,doc.internal.pageSize.getHeight()-margin*2)
}

function line(p, direct='h',margin=5, end=margin){

    if(direct == 'h'){
        doc.line(margin,p,txt.dim[0]-end,p)
    }else{
        doc.line(p,margin,p,txt.dim[1]-end)
    }

}

function logo(pos = [14,7,36,25]){
    doc.addImage(imgData, 'png', pos[0], pos[1], pos[2], pos[3]);
}

function plotImg(url,x,y,w){
    var foto = new Image()
    foto.src = url+'?'+ new Date().getTime()
    doc.addImage(foto, 'png', x,y,w,0);
}

function px2mm(px){
    return px/96*25.4
}

function backLine(N=1){
    txt.y -= txt.lineHeigth * N
    return true
}

function negrito(sign,text,x,y){

    const negrito = text.split(sign)
    doc.text(negrito[0].trim(),x,y)
    x += doc.getTextWidth(negrito[0].trim()+'  ')
    for(let k=1; k<negrito.length; k++){
        doc.setFont(undefined, 'bold')
        const after = negrito[k].split(' ') 
        doc.text(after[0].trim(),x,y)
        x += doc.getTextWidth(after[0].trim())
        doc.setFont(undefined, 'normal')
        if(after.length>1){
            doc.text(negrito[k].replaceAll(after[0].trim(),'') ,x,y)
        }
    }

}

function box(text,x,y,w,lh=0.8){
    const h = txt.lineHeigth * lh   
    text = text.trim().split('\n')

    for(let i=0; i<text.length; i++){
        const txt = text[i].trim().split(' ')
        let lin = ''
        for(let j=0; j<txt.length; j++){
            if(doc.getTextDimensions(lin+txt[j]+' ').w < w ){
                lin +=  txt[j] + ' '
            }else{
                negrito('@#',lin.trim(),x,y)
//                doc.text(lin.trim(),x,y)

                y = y+h
                lin =  txt[j] + ' '
                addLine()
            }
        }
        lin.trim().length >0 ? negrito('@#',lin,x,y): null;
//        lin.trim().length >0 ? doc.text(lin,x,y): null;
        y += h
        addLine()
    }    
}

function center_text(T='',box=[0,doc.internal.pageSize.getWidth()]){
    const text = T==''? txt.text : T
    const w = doc.getTextDimensions(T).w
    const xOffset = (box[1] - box[0] - w) /2;  
    doc.text(T, box[0] + xOffset, txt.y);
    addLine()
}

function right_text(T='',margin=0, pos=doc.internal.pageSize.getWidth()){
    const text = T==''? txt.text : T
    const w = doc.getTextDimensions(T).w
    const xOffset = pos - margin - w 
    doc.text(T, xOffset, txt.y);
}

function block_text(T=''){
    const text = T==''? txt.text.split(' ') : T.split(' ')
    let line = ''

    function print(){

        if(line.length > 0){
            doc.text(line.trim(), txt.x, txt.y);
        }
        addLine()
        line = ''
        if (txt.y >= txt.dim[1]){
            addPage(46)
        }                
    }

    for(let i=0; i< text.length; i++){

        if(text[i].includes('\n')){
            line = line.trim() + ' ' + text[i].trim()
            print()
        }else if(text[i] != ''){
            line = line.trim() + ' ' + text[i].trim()
        }

        length = line.length * (doc.internal.getFontSize() / 4.6)
        if(length > txt.width){
            print()
        }                
    }
    print()
}

function header_pdf(lin_h = 5, font_size = 12){
    ini_y = 13
    doc.addImage(imgData, 'png', 0,100,100,100);
    //  CABEÇALHO
    doc.setFontSize(font_size)
    doc.setFont(undefined, 'normal')
}

function openPDF(doc,filename){
    const file = doc.output('blob')
    return uploadFile(file,`config/user/${localStorage.getItem('id_user')}/temp/`,`${filename}.pdf`).then(()=>{
        window.open(window.location.href+`config/user/${localStorage.getItem('id_user')}/temp/${filename}.pdf`, '_blank').focus();
        loading()
    })
}

function savePDF(doc,path,filename){
    const file = doc.output('blob')
    return uploadFile(file,path,filename).then(()=>{
//        window.open(window.location.href+path+filename, '_blank').focus();
        loading()
    })
}