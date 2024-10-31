String getTypeName(String shortName){
  if(shortName == "qr"){
    return "QR Kod ile";
  }else if(shortName == "barcode"){
    return "Barkod ile";
  }else if(shortName == "image"){
    return "Görüntü ile";
  }else{
    return "Ses ile";
  }
}