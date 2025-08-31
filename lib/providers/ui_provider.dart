import 'package:flutter/material.dart';


class UIProvider extends ChangeNotifier {

  int _marcadorActual = 0;

  List<String> _flippedCards = []; // Lista de tarjetas volteadas

  List<String> _cardsRemoved = []; // Lista de tarjetas removidas

  int get marcadorActual => _marcadorActual;

  var _limpiar = false;

  var _isgamewon=false;



  set marcadorActual(int valor){
    _marcadorActual = valor;
    notifyListeners();
  }

  List<String> get flippedCards => _flippedCards;

  set flippedCards(List<String> valor){
    _flippedCards = valor;
    notifyListeners();
  }

  void addFlippedCard(String cardIndex){
    _flippedCards.add(cardIndex);
    notifyListeners();
  }

  void removeFlippedCard(String cardIndex){
    _flippedCards.remove(cardIndex);
    notifyListeners();
  }

  void resetFlippedCards(){
    _flippedCards = [];
    _limpiar = true;
    notifyListeners();
  }

  //comprobar si los id del arreglo de cartas volteadas son iguales
   checkFlippedCards(){
    if(_flippedCards.length == 2){
      if(_flippedCards[0] == _flippedCards[1]){
        return true;
      }
    }
    return false;
  }

   isCardFlipped(cardIndex){
    if(_flippedCards.contains(cardIndex)){
      return true;
    }
    return false;
  }

  removeCard(cardIndex){
    _cardsRemoved.add(cardIndex);
    notifyListeners();
  }


  void resetMarcador(){
    _marcadorActual = 0;
    notifyListeners();
  }

  void addMarcador(){
    _marcadorActual++;
    notifyListeners();
  }

  void removeMarcador(){
    _marcadorActual--;
    notifyListeners();
  }

  List<String> get cardsRemoved => _cardsRemoved;

  set cardsRemoved(List<String> valor){
    _cardsRemoved = valor;
    notifyListeners();
  }

  void addCardRemoved(String cardIndex){
    _cardsRemoved.add(cardIndex);
    notifyListeners();
  }

  void removeCardRemoved(String cardIndex){
    _cardsRemoved.remove(cardIndex);
    notifyListeners();
  }

  void resetCardRemoved(){
    _cardsRemoved = [];
    notifyListeners();
  }
  checkCardRemoved(cardIndex){
    if(_cardsRemoved.contains(cardIndex)){
      return true;
    }
    return false;
  }

   get limpiar => _limpiar;

  set limpiar(var valor){
    _limpiar = valor;
    notifyListeners();
  }

get isGameWon => _isgamewon;

  set isGameWon(var valor){
    _isgamewon = valor;
    notifyListeners();
  }

  void resetGameWon(){
    _isgamewon = false;
    notifyListeners();
  }

 

  void resetGame(){
    _marcadorActual = 0;
    _flippedCards = [];
    _cardsRemoved = [];
    _limpiar = false;
    _isgamewon = false;
    notifyListeners();
  }






}