{Unidad ogDefObjGraf 1.3
======================
Por Tito Hinostroza 25/07/2014
* Se cambia nombre de TObjVsible.x aTObjVsible.fx y de TObjVsible.y a TObjVsible.fy
* Se crean las propiedades X e Y para acceder a las coordenadas del objeto.
* Se agrega el método Delete(), para eliminar a un objeto gráfico.
* Se agregan los objetos TogCheckBox y TogScrollBar
* Se cambia de nombre a Tbot por TogButton

Descripcion
===========
Define a los objetos gráficos primarios que serán usados por los objetos de mayor nivel
a usar en un editor de objetos gráficos.
El objeto TObjGraf, es el objeto base del que deben derivarse los objetos más específicos
que se dibujarán en pantalla.
Se incluyen también la definición de puntos de control, que permiten redimensionar al
objeto; y de botones que pueden incluirse en los objetos graficos.
En esta unidad solo deben estar definidos los objetos básicos, los que se pueden usar en
muchas aplicaciones. Los más específicos se deben poner en otra unidad.
No se recomienda modificar esta unidad para adecuar los objetos gráficos a la aplicación.
Si se desea manjar otra clase de objetos generales, es mejor crear otra clase general a
partir de TObjGraf.
La jerarquía de clases es:

TObjVisible ---------------------------------------> TObjGraf ---> Derivar objetos aquí
              |                                        |
               --> TPtoCtrl --(Se incluyen en)---------
              |                                        |
               --> TogButton --(Se pueden incluir en)--
              |                                        |
               --> TCheckBox --(Se pueden incluir en)--

}
unit ogDefObjGraf;
{$mode objfpc}{$H+}
interface
uses  Classes, Controls, SysUtils, Fgl, Graphics, GraphType, Types, ExtCtrls,
  ogMotGraf2D;

const
  ANCHO_MIN = 20;    //Ancho mínimo de objetos gráficos en pixels (Coord Virtuales)
  ALTO_MIN = 20;     //Alto mínimo de objetos gráficos en Twips (Coord Virtuales)

type
  { TObjVsible }
  //Clase base para todos los objetos visibles
  TObjVsible = class
  protected
    fx,fy      : Single;     //coordenadas virtuales
    v2d        : TMotGraf;   //motor gráfico
    Xant,Yant  : Integer;    //coordenadas anteriores
  public
    Id          : Integer;     //identificador del objeto
    ancho, alto : Single;
    Seleccionado: Boolean;
    NombreObj   : String;     //Nombre de Objeto, usado para identificarlo
                              //dentro de una colección.
    visible    : boolean;  //indica si el objeto es visible
    procedure Crear(mGraf: TMotGraf; ancho0, alto0: Integer);  //no es constructor
    procedure Ubicar(x0, y0: Single);  //Fija posición
    function LoSelec(xr, yr: Integer): Boolean;
    function InicMover(xr, yr: Integer): Boolean;
    property x: Single read fx;
    property y: Single read fy;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TPosicPCtrol = (   //tipo de desplazamiento de punto de control
    TD_SIN_POS,  //sin posición. No se reubicará automáticamente
    TD_SUP_IZQ,  //superior izquierda, desplaza ancho (por izquierda) y alto (por arriba)
    TD_SUP_CEN,  //superior central, desplaza alto por arriba
    TD_SUP_DER,  //superior derecha, desplaza ancho (por derecha) y alto (por arriba)

    TD_CEN_IZQ,  //central izquierda, desplaza ancho (por izquierda)
    TD_CEN_DER,  //central derecha, desplaza ancho (por derecha)

    TD_INF_IZQ,  //inferior izquierda
    TD_INF_CEN,  //inferior central
    TD_INF_DER   //inferior izquierda
   );

  //Procedimiento-evento para dimensionar forma
  TEvenPCdim = procedure(x,y,ancho,alto: Single) of object;

  { TPtoCtrl }
  TPtoCtrl = class(TObjVsible)
  private
    fTipDesplaz: TPosicPCtrol;
    procedure SetTipDesplaz(AValue: TPosicPCtrol);
  public
    posicion   : TPosicPCtrol;  //solo hay 8 posicionnes para un punto de control
    //El tipo de desplazamiento, por lo general debe depender  nicamente de la posicion
    property tipDesplaz: TPosicPCtrol read fTipDesplaz write SetTipDesplaz;
    constructor Crear(mGraf: TMotGraf; PosicPCtrol, tipDesplaz0: TPosicPCtrol;
      EvenPCdim0: TEvenPCdim);
    procedure Dibujar();
    procedure InicMover(xr, yr: Integer; x0, y0, ancho0, alto0: Single);
    procedure Mover(xr, yr: Integer);  //Dimensiona las variables indicadas
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
    function LoSelec(xp, yp: Integer):boolean;
  private
    tipPuntero : Integer;  //Tipo de puntero
    EvenPCdim: TEvenPCdim;  //manejador de Evento
    x1, y1, ancho1, alto1: Single;  //valores objetivo para las dimensiones
  end;
  TPtosControl = specialize TFPGObjectList<TPtoCtrl>;  //Lista para gestionar los puntos de control

  { Objeto Tbot - Permite gestionar los botones}

//Procedimiento-evento para evento Click en Botón
  TEvenBTclk = procedure(estado: Boolean) of object;

  TTipBot =
   (BOT_CERRAR,   //botón cerrar
    BOT_EXPAND,   //botón expandir/contraer
    BOT_CHECK,    //check
    BOT_REPROD);   //reproducir/detener

  TSBOrientation =
   (SB_HORIZONT,    //horizontal
    SB_VERTICAL);   //vertical

  { TogButton }
  TogButton = class(TObjVsible)
    estado     : Boolean;   //Permite ver el estado del botón o el check
    drawBack   : boolean;   //indica si debe dibujar el fondo
    constructor Create(mGraf: TMotGraf; tipo0: TTipBot; EvenBTclk0: TEvenBTclk);
    procedure Dibujar;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
  private
    tipo       : TTipBot;
    OnClick: TEvenBTclk
  end;

  { TogCheckBox }
  TogCheckBox = class(TObjVsible)
    estado     : Boolean;   //Permite ver el estado del botón o el check
    constructor Create(mGraf: TMotGraf; ancho0,alto0: Integer; tipo0: TTipBot; EvenBTclk0: TEvenBTclk);
    procedure Dibujar;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
  private
    tipo       : TTipBot;
    OnClick: TEvenBTclk
  end;

  { TogScrollBar }
  //Este ScrollBar está diseñado para manejara desplazamientos con valores discretos
  TogScrollBar = class(TObjVsible)
    valMin   : integer;   //valor mínimo
    valMax   : integer;   //valor máximo
    valCur   : integer;   //valor actual
    step     : integer;   //valor del paso
    page     : integer;      //cantidad de elementos por página
    pulsado  : boolean;   //bandera para temporización
    constructor Create(mGraf: TMotGraf; tipo0: TSBOrientation; EvenBTclk0: TEvenBTclk);
    destructor Destroy; override;
    procedure Scroll(delta: integer);  //desplaza el valor del cursor
    procedure Dibujar;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
    procedure procButDown(estado: Boolean);
    procedure procButUp(estado: Boolean);
    procedure ProcTic(Sender: TObject);
  private
    tipo       : TSBOrientation;
    butUp      : TogButton;
    butDown    : TogButton;
    OnClick    : TEvenBTclk;
    clock      : TTimer;     //temporizador para leer salida del proceso
    ticCont    : integer;    //contador
  end;

  TogButtons = specialize TFPGObjectList<TogButton>;       //Para gestionar los botones
  TogScrollBars = specialize TFPGObjectList<TogScrollBar>; //Para gestionar barras de desplazamiento

  TObjGraf = class;
  TEventSelec = procedure(obj: TObjGraf) of object; //Procedimiento-evento para seleccionar
  TEventCPunt = procedure(TipPunt: Integer) of object; //Procedimiento-evento para cambiar puntero

  { TObjGraf }
  {Este es el Objeto padre de todos los objetos gráficos visibles que son administrados por el
   motor de edición}
  TObjGraf = class(TObjVsible)
  private
    procedure ProcPCdim(x0, y0, ancho0, alto0: Single);
  protected
    pcx        : TPtoCtrl;      //variable para Punto de Control
    PtosControl: TPtosControl;  //Lista de puntos de control
    Buttons    : TogButtons;    //Lista para contener botones
    ScrollBars : TogScrollBars; //Lista para contener barras de desplazamiento
    //puntos de control por defecto
    pc_SUP_IZQ: TPtoCtrl;
    pc_SUP_CEN: TPtoCtrl;
    pc_SUP_DER: TPtoCtrl;
    pc_CEN_IZQ: TPtoCtrl;
    pc_CEN_DER: TPtoCtrl;
    pc_INF_IZQ: TPtoCtrl;
    pc_INF_CEN: TPtoCtrl;
    pc_INF_DER: TPtoCtrl;
    procedure ReubicElemen; virtual;
    procedure ReConstGeom; virtual; //Reconstruye la geometría del objeto
    function SelecPtoControl(xp, yp: integer): TPtoCtrl;
  public
    nombre      : String;    //Identificación del objeto
    Marcado     : Boolean;   //Indica que está marcado, porque el ratón pasa por encima
    DibSimplif  : Boolean;   //indica que se está en modo de dibujo simplificado
    TamBloqueado: boolean;   //protege al objeto de redimensionado
//  Bloqueado   : Boolean;   //Indica si el objeto está bloqueado
    tipo        : Integer;   //Tipo de objeto
    Relleno     : TColor;    //Color de relleno
    Proceso     : Boolean;   //Bandera
    Dimensionando: boolean;  //indica que el objeto está dimensionándose
    Erased      : boolean;   //bandera para eliminar al objeto
    //Eventos de la clase
    OnSelec  : TEventSelec;
    OnDeselec: TEventSelec;
    OnCamPunt: TEventCPunt;
    function XCent: Single;  //Coordenada Xcentral del objeto
    function YCent: Single;  //Coordenada Ycentral del objeto
    procedure Ubicar(x0, y0: Single);
    procedure Selec;         //Método único para seleccionar al objeto
    procedure Deselec;       //Método único para quitar la selección del objeto
    procedure Delete;        //Método para eliminar el objeto
    procedure Mover(xr, yr : Integer; nobjetos : Integer); virtual;
    function LoSelecciona(xr, yr:integer): Boolean;
    procedure Dibujar; virtual;  //Dibuja el objeto gráfico
    procedure LeePropiedades(cad: string; grabar_ini: boolean=true); virtual; abstract;
    procedure InicMover(xr, yr : Integer);
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
       xp, yp: Integer); virtual;  //Metodo que funciona como evento mouse_down
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
       xp, yp: Integer; solto_objeto: Boolean); virtual;
    procedure MouseMove(Sender: TObject; Shift: TShiftState; xp, yp: Integer); virtual;
    procedure MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
                 MousePos: TPoint; var Handled: Boolean); virtual;
    function AddButton(ancho0, alto0: Integer; tipo0: TTipBot;
      EvenBTclk0: TEvenBTclk): TogButton;
    function AgregarPtoControl(PosicPCtrol, tipDesplaz0: TPosicPCtrol): TPtoCtrl;
    function AddScrollBar(ancho0, alto0: Integer; tipo0: TSBOrientation;
      EvenBTclk0: TEvenBTclk): TogScrollBar;
    constructor Create(mGraf: TMotGraf); virtual;
    destructor Destroy; override;
  end;

implementation

const
  ANC_PCT2 = 5;       //mitad del ancho de punto de control

{ TObjVsible }
procedure TObjVsible.Crear(mGraf: TMotGraf; ancho0, alto0: Integer);
begin
  v2d := mGraf;
  ancho:=ancho0;
  alto :=alto0;
  visible := true;
end;
procedure TObjVsible.Ubicar(x0, y0: Single);
begin
  fx := x0;
  fy := y0;
end;
function TObjVsible.LoSelec(xr, yr: Integer): Boolean;
//Indica si las coordenadas de ratón seleccionan al botón en su posición actual
var xv, yv: Single;    //coordenadas virtuales
begin
    v2d.XYvirt(xr, yr, xv, yv);
    LoSelec := False;    //valor por defecto
    If (xv > fx - 2) And (xv < fx + ancho + 2) And
       (yv > fy - 2) And (yv < fy + alto + 2) Then
        LoSelec := True;
end;
function TObjVsible.InicMover(xr, yr: Integer): Boolean;
begin
    if not visible then exit;    //validación
    //captura posición actual, para calcular los desplazamientos
    Xant := xr;
    Yant := yr;
end;
constructor TObjVsible.Create;
begin
  inherited Create;
end;
destructor TObjVsible.Destroy;
begin
  inherited Destroy;
end;

{ TogCheckBox }
constructor TogCheckBox.Create(mGraf: TMotGraf; ancho0, alto0: Integer;
  tipo0: TTipBot; EvenBTclk0: TEvenBTclk);
begin

end;
procedure TogCheckBox.Dibujar;
//Dibuja el botón de acuerdo a su tipo y estado
begin
  case tipo of
  BOT_CERRAR: begin
//       v2d.DibFonBoton(fx,fy,15,15);
       v2d.DibVnormal(fx+2,fy+2,10,5);
       v2d.DibVnormal(fx+2,fy+12,10,-5);
     end;
  BOT_EXPAND:
      if estado then begin
//         v2d.DibFonBoton(fx,fy,15,15);
//         v2d.DibVnormal(fx+2,fy+7,10,-5);
//         v2d.DibVnormal(fx+2,fy+11,10,-5);
         v2d.FijaColor(COL_GRIS, COL_GRIS, 1);
         v2d.poligono(fx+3      , fy + alto-5,
                      fx+ancho-3, fy + alto-5,
                      fx+ancho/2, fy + 4);
      end else begin
//         v2d.DibFonBoton(fx,fy,15,15);
//         v2d.DibVnormal(fx+2,fy+2,10,5);
//         v2d.DibVnormal(fx+2,fy+6,10,5);
        v2d.FijaColor(COL_GRIS, COL_GRIS, 1);
        v2d.poligono(fx+3      , fy + 5,
                     fx+ancho-3, fy + 5,
                     fx+ancho/2, fy + alto - 4);
      end;
  BOT_CHECK: begin  //botón check
     if estado then begin   //dibuja solo borde
        v2d.DibBorBoton(fx,fy,15,15);
     end else begin         //dibuja con check
        v2d.DibBorBoton(fx,fy,15,15);
        v2d.DibCheck(fx+2,fy+2,10,8);
     end;
    end;
  BOT_REPROD: begin  //botón reproducir
     if estado then begin   //dibuja solo borde
       v2d.FijaColor(clBlack, TColor($E5E5E5), 1);
       v2d.RectRedonR(fx,fy,fx+ancho, fy+alto);
       v2d.FijaColor(clBlack, clBlack, 1);
       v2d.RectangR(fx+6,fy+6,fx+ancho-6, fy+alto-6);
     end else begin         //dibuja con check
       v2d.FijaColor(clBlack, TColor($E5E5E5), 1);
       v2d.RectRedonR(fx,fy,fx+ancho, fy+alto);
       v2d.FijaColor(clBlack, clBlack, 1);
       v2d.poligono(fx+6, fy+3,
                    fx+18, fy + alto/2,
                    fx+6, fy + alto - 4);
     end;
    end;
  end;
end;
procedure TogCheckBox.MouseUp(Button: TMouseButton; Shift: TShiftState; xp,
  yp: Integer);
begin

end;

{ TogButton }
constructor TogButton.Create(mGraf: TMotGraf; tipo0: TTipBot;
  EvenBTclk0: TEvenBTclk);
begin
   inherited Crear(mGraf, 16, 16);    //crea
   tipo := tipo0;
   OnClick := EvenBTclk0;
   estado := FALSE;   //inicia en 0 (check no marcado, o botón por contraer)
   drawBack := true;
end;
procedure TogButton.Dibujar;
//Dibuja el botón de acuerdo a su tipo y estado
begin
  case tipo of
  BOT_CERRAR: begin
       if drawBack then v2d.DibBorBoton(fx,fy,ancho,alto);
       v2d.DibVnormal(fx+2,fy+2,10,5);
       v2d.DibVnormal(fx+2,fy+12,10,-5);
     end;
  BOT_EXPAND:
      if estado then begin
        if drawBack then v2d.DibBorBoton(fx,fy,ancho,alto);
//         v2d.DibVnormal(fx+2,fy+7,10,-5);
//         v2d.DibVnormal(fx+2,fy+11,10,-5);
         v2d.FijaColor(COL_GRIS, COL_GRIS, 1);
         v2d.DrawTrianUp(fx+2,fy+4,ancho-4,alto-10);
      end else begin
         if drawBack then v2d.DibBorBoton(fx,fy,ancho,alto);
//         v2d.DibVnormal(fx+2,fy+2,10,5);
//         v2d.DibVnormal(fx+2,fy+6,10,5);
        v2d.FijaColor(COL_GRIS, COL_GRIS, 1);
        v2d.DrawTrianDown(fx+2,fy+5,ancho-4,alto-10);
      end;
  BOT_CHECK: begin  //botón check
     if estado then begin   //dibuja solo borde
        v2d.DibBorBoton(fx,fy,15,15);
     end else begin         //dibuja con check
        v2d.DibBorBoton(fx,fy,15,15);
        v2d.DibCheck(fx+2,fy+2,10,8);
     end;
    end;
  BOT_REPROD: begin  //botón reproducir
     if estado then begin   //dibuja solo borde
       v2d.FijaColor(clBlack, TColor($E5E5E5), 1);
       v2d.RectRedonR(fx,fy,fx+ancho, fy+alto);
       v2d.FijaColor(clBlack, clBlack, 1);
       v2d.RectangR(fx+6,fy+6,fx+ancho-6, fy+alto-6);
     end else begin         //dibuja con check
       v2d.FijaColor(clBlack, TColor($E5E5E5), 1);
       v2d.RectRedonR(fx,fy,fx+ancho, fy+alto);
       v2d.FijaColor(clBlack, clBlack, 1);
       v2d.poligono(fx+6, fy+3,
                    fx+18, fy + alto/2,
                    fx+6, fy + alto - 4);
     end;
    end;
  end;
end;
procedure TogButton.MouseUp(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
begin
   if LoSelec(xp,yp) then begin    //se soltó en el botón
      //cambia el estado, si aplica
      if tipo in [BOT_EXPAND, BOT_CHECK, BOT_REPROD] then estado := not estado;
      if Assigned(OnClick) then
         OnClick(estado);    //ejecuta evento
   end;
end;

{ TogScrollBar }
constructor TogScrollBar.Create(mGraf: TMotGraf; tipo0: TSBOrientation;
  EvenBTclk0: TEvenBTclk);
begin
  inherited Crear(mGraf, 16, 50);    //crea
  clock := TTimer.Create(nil);
  clock.interval:=250;  //ciclo de conteo
  clock.OnTimer:=@ProcTic;
  tipo := tipo0;
  OnClick := EvenBTclk0;
  valMin:=0;
  valMax:=255;
  pulsado := false;   //limpia bandera para detectar pulsado contínuo.
  ticCont := 0;       //inicia contador
  case tipo of
  SB_HORIZONT: begin
      ancho:=80; alto:=19;  {se usa 19 de ancho porque así tendremos a los botones con
                             16, que es el tamño en el que mejor se dibuja}
    end;
  SB_VERTICAL: begin
      ancho:=19; alto:=80;
    end;
  end;
  //crea botones
  butUp := TogButton.Create(mGraf,BOT_EXPAND, @procButUp);
  butUp.drawBack:=false;
  butUp.estado:=true;
  butDown := TogButton.Create(mGraf,BOT_EXPAND, @procButDown);
  butDown.drawBack:=false;
  butDown.estado:=false;
end;
destructor TogScrollBar.Destroy;
begin
  butUp.Destroy;
  butDown.Destroy;
  clock.Free;  //destruye temporizador
  inherited Destroy;
end;
procedure TogScrollBar.Scroll(delta: integer);
//Desplaza el cursor en "delta" unidades.
begin
  valCur += delta;
//   if valCur  > valMax then valCur := valMax;
  if valCur + page - 1 > valMax then valCur := valMax - page + 1;
  if valCur < valMin then valCur := valMin;
  if OnClick<>nil then OnClick(true);
end;
procedure TogScrollBar.procButDown(estado: Boolean);
begin
  Scroll(1);
end;
procedure TogScrollBar.procButUp(estado: Boolean);
begin
  Scroll(-1);
end;
procedure TogScrollBar.ProcTic(Sender: TObject);
begin
  //Se verifica si los botones están pulsados
  inc(ticCont);

end;
procedure TogScrollBar.Dibujar;
const
  ALT_MIN_CUR = 10;
var
  altBot: Single;
  y2: Extended;
  facPag: Single;
  espCur: Single;
  altCur: Single;
  yIni, yFin: Single;
  yDesp: SIngle;
begin
  case tipo of
  SB_HORIZONT: begin
    end;
  SB_VERTICAL: begin
      v2d.FijaLapiz(psSolid, 1, clScrollBar);
      v2d.FijaRelleno(clMenu);
      v2d.rectangR(fx,fy,fx+ancho,fy+alto);  //fondo

      butUp.fx:=fx+1;
      butUp.ancho:=ancho-3;
      butUp.fy:=fy;

      butDown.fx:=fx+1;
      butDown.ancho:=ancho-3;
      butDown.fy:=fy+alto-butDown.alto;

      butUp.Dibujar;
      butDown.Dibujar;
      //dibuja líneas
      altBot := butUp.alto;
      y2 := fy + alto;
      yIni := fy+altBot;
      yFin := y2-altBot;
      v2d.FijaLapiz(psSolid, 1, clScrollBar);
      v2d.FijaRelleno(clScrollBar);
      v2d.Linea(fx,yIni,fx+ancho,yIni);
      v2d.Linea(fx,yFin,fx+ancho,yFin);
      //dibuja cursor
      facPag := page/(valMax-valMin+1);  //factor de página
      espCur := yFin-yIni;  //espacio disponible para desplazamiento del cursor
      if espCur > ALT_MIN_CUR then begin
         altCur := facPag * espCur;
         if altCur<ALT_MIN_CUR then altCur:= ALT_MIN_CUR;
         //dibuja cursor
         yDesp := (valCur-valMin)/(valMax-valMin+1)*espCur;
         if espCur<=altCur then exit;   //protección
         yIni := yIni + yDesp*(espCur-altCur)/(espCur-facPag * espCur);
         if yIni+altCur > yFin then exit;   //protección
         v2d.RectangR(fx,yIni,fx+ancho,yIni+altCur);
      end;
    end;
  end;
end;
procedure TogScrollBar.MouseUp(Button: TMouseButton; Shift: TShiftState; xp,
  yp: Integer);
begin
  pulsado := false;   //limpia bandera
  ticCont := 0;
  //pasa eventos
//  butUp.MouseUp(Button, Shift, xp, yp);
//  butDown.MouseUp(Button, Shift, xp, yp);
end;
procedure TogScrollBar.MouseDown(Button: TMouseButton; Shift: TShiftState; xp,
  yp: Integer);
begin
  pulsado := true;   //marca bandera
  //pasa eventos como si fueran MouseUP, porque las barras de desplazamiento deben
  //responder rápidamente.
  butUp.MouseUp(Button, Shift, xp, yp);
  butUp.estado:=true;     //para que no cambie el ícono
  butDown.MouseUp(Button, Shift, xp, yp);
  butDown.estado:=false;  //para que no cambie el ícono
end;

{ TObjGraf }
function TObjGraf.SelecPtoControl(xp, yp:integer): TPtoCtrl;
//Indica si selecciona a algún punto de control y devuelve la referencia.
var pdc: TPtoCtrl;
begin
  SelecPtoControl := NIL;      //valor por defecto
  for pdc in PtosControl do
      if pdc.LoSelec(xp,yp) then begin SelecPtoControl := pdc; Exit; end;
end;
function TObjGraf.XCent: Single;
begin
   Result := fx + Ancho / 2;
end;
function TObjGraf.YCent: Single;
begin
   Result := fy + Alto / 2;
end;
procedure TObjGraf.Selec;
begin
   if Seleccionado then exit;    //ya está seleccionado
   Seleccionado := true; //se marca como seleccionado
   //Llama al evento que selecciona el objeto. El editor debe responder
   if Assigned(OnSelec) then OnSelec(self);   //llama al evento
   { TODO : Aquí se debe activar los controles para dimensionar el objeto }
end;
procedure TObjGraf.Deselec;
begin
   if not Seleccionado then exit;    //ya está seleccionado
   Seleccionado := false; //se marca como selccionado
   //Llama al evento que selecciona el objeto. El editor debe responder
   if Assigned(OnDeselec) then OnDeselec(self);  //llama al evento
   { TODO : Aquí se debe desactivar los controles para dimensionar el objeto }
end;
procedure TObjGraf.Delete;
begin
  //Marca para eliminarse
  Erased := true;
end;
procedure TObjGraf.Mover(xr, yr: Integer; nobjetos: Integer);
{Metodo que funciona como evento movimiento al objeto
"nobjetos" es la cantidad de objetos que se mueven. Ususalmente es sólo uno}
var dx , dy: Single;
begin
//     If ArrastBoton Then Exit;       //Arrastrando botón  { TODO : Revisar }
//     If ArrastFila Then Exit;        //Arrastrando botón  { TODO : Revisar }
     If Seleccionado Then begin
        v2d.ObtenerDesplaz2( xr, yr, Xant, Yant, dx, dy);
        if Proceso then   //algún elemento del objeto ha procesado el evento de movimiento
           begin
              if pcx <> NIL then begin
                 //hay un punto de control procesando el evento MouseMove
                 if not TamBloqueado then
                   pcx.Mover(xr, yr);   //permite dimensionar el objeto
              end;
//              Proceso := True;  'ya alguien ha capturado el evento
           end
        else  //ningún elemento del objeto lo ha procesado, pasamos a mover todo el objeto
           begin
              fx := fx + dx; fy := fy + dy;
              ReubicElemen;  //reubica los elementos
              Proceso := False;
           End;
        Xant := xr; Yant := yr;
     End;
end;

function TObjGraf.LoSelecciona(xr, yr:integer): Boolean;
//Devuelve verdad si la coordenada de pantalla xr,yr cae en un punto tal
//que "lograria" la seleccion de la forma.
var xv , yv : Single; //corodenadas virtuales
begin
    v2d.XYvirt(xr, yr, xv, yv);
    LoSelecciona := False; //valor por defecto
    //verifica área de selección
    If (xv > fx - 1) And (xv < fx + Ancho + 1) And (yv > fy - 1) And (yv < fy + Alto + 1) Then
      LoSelecciona := True;
    if Seleccionado then begin   //seleccionado, tiene un área mayor de selección
      if SelecPtoControl(xr,yr) <> NIL then LoSelecciona := True;
    end;
End;
procedure TObjGraf.Dibujar;
const tm = 3;
var
  pdc  : TPtoCtrl;
  bot  : TogButton;
  sbar : TogScrollBar;
begin
  //dibuja Buttons
  for bot in Buttons do bot.Dibujar;     //Dibuja Buttons
  for sbar in ScrollBars do sbar.Dibujar;
  //---------------dibuja remarcado --------------
  If Marcado Then begin
    v2d.FijaLapiz(psSolid, 2, clBlue);   //RGB(128, 128, 255)
    v2d.rectang(fx - tm, fy - tm, fx + ancho + tm, fy + alto + tm);
  End;
  //---------------dibuja marca de seleccion--------------
  If Seleccionado Then begin
//    v2d.FijaLapiz(psSolid, 1, clGreen);
//    v2d.rectang(fx, fy, fx + ancho, fy + alto);
     for pdc in PtosControl do pdc.Dibujar;   //Dibuja puntos de control
  End;
end;
procedure TObjGraf.InicMover(xr, yr: Integer);
//Procedimiento para procesar el evento InicMover de los objetos gráficos
//Se ejecuta al inicio de movimiento al objeto
begin
  Xant := xr; Yant := yr;
  Proceso := False;
  if not seleccionado then exit;   //para evitar que responda antes de seleccionarse
  //Busca si algún punto de control lo procesa
  pcx := SelecPtoControl(xr,yr);
  if pcx <> NIL  then begin
      pcx.InicMover(xr, yr, fx, fy,ancho,alto);     //prepara para movimiento fy dimensionamiento
      Proceso := True;      //Marcar para indicar al editor fy a Mover() que este objeto procesará
                            //el evento fy no se lo pasé a los demás que pueden estar seleccionados.
      Dimensionando := True; //Marca bandera
   end;
  { TODO : Verificar por qué, a veces se puede iniciar el movimiento del objeto cuando el puntero está en modo de dimensionamiento. }
end;
procedure TObjGraf.MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
//Metodo que funciona como evento "MouseDown"
begin
//  CapturoEvento := NIL;
  Proceso := False;
  If LoSelecciona(xp, yp) Then begin  //sólo responde instantáneamente al caso de selección
    If Not Seleccionado Then Selec;
    Proceso := True;{ TODO : Verificar si es útil la bandera "Proceso" }
  End;
End;
procedure TObjGraf.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; xp, yp: Integer; solto_objeto: Boolean);
//Metodo que funciona como evento MouseUp
//la bandera "solto_objeto" indica que se ha soltado el objeto despues de estarlo arrastrando
var
  bot: TogButton;
  sbar : TogScrollBar;
begin
    Proceso := False;
    //verifica si cae de un arrastre
    If solto_objeto And Seleccionado Then begin
        Proceso := True; Exit;    //no quita la selección
    end;
    //Se soltó el ratón
    If Button = mbLeft Then  begin          //soltó izquierdo
       //pasa evento a los controles
       for bot in Buttons do bot.MouseUp(Button, Shift, xp, yp);
       for sbar in ScrollBars do sbar.MouseUp(Button, Shift, xp, yp);
    end else If Button = mbRight Then begin //soltó derecho
        If LoSelecciona(xp, yp) Then
            Proceso := True;
    end;
    //Restaura puntero si estaba dimensionándose por si acaso
    if Dimensionando then begin
       if not pcx.LoSelec(xp,yp) then //se salio del foco
          if Assigned(OnCamPunt) then OnCamPunt(crDefault);  //pide retomar el puntero
       Dimensionando := False;    //quita bandera, por si estaba dimensionando
       exit;
    end;
end;
procedure TObjGraf.MouseMove(Sender: TObject; Shift: TShiftState; xp, yp: Integer);
//Respuesta al evento MouseMove. Se debe recibir cuando el Mouse pasa por encima del objeto
var pc: TPtoCtrl;
begin
    if not Seleccionado then Exit;
    //Aquí se supone que tomamos el control porque está seleccionado
    //Procesa el cambio de puntero.
    if Assigned(OnCamPunt) then begin
        pc := SelecPtoControl(xp,yp);
        if pc<> NIL then
           OnCamPunt(pc.tipPuntero)  //cambia a supuntero
        else
           OnCamPunt(crDefault);
    end;
end;
procedure TObjGraf.MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin

end;

constructor TObjGraf.Create(mGraf: TMotGraf);
begin
  inherited Create;
  erased := false;
  v2d := mGraf;   //asigna motor gráfico
  ancho := 100;   //ancho por defecto
  alto := 100;    //alto por defecto
  fx := 100;
  fy := 100;
  PtosControl:= TPtosControl.Create(True);   //Crea lista con administración de objetos
  Buttons    := TogButtons.Create(True);     //Crea lista con administración de objetos
  ScrollBars := TogScrollBars.Create(True);
  Seleccionado := False;
  Marcado := False;
  Proceso := false;
  DibSimplif := false;
  //Crea puntos de control estándar. Luego se pueden eliminar fy crear nuevos o modificar
  //estos puntos de control.
  pc_SUP_IZQ:=AgregarPtoControl(TD_SUP_IZQ, TD_SUP_IZQ);
  pc_SUP_CEN:=AgregarPtoControl(TD_SUP_CEN, TD_SUP_CEN);
  pc_SUP_DER:=AgregarPtoControl(TD_SUP_DER, TD_SUP_DER);
  pc_CEN_IZQ:=AgregarPtoControl(TD_CEN_IZQ, TD_CEN_IZQ);
  pc_CEN_DER:=AgregarPtoControl(TD_CEN_DER, TD_CEN_DER);
  pc_INF_IZQ:=AgregarPtoControl(TD_INF_IZQ, TD_INF_IZQ);
  pc_INF_CEN:=AgregarPtoControl(TD_INF_CEN, TD_INF_CEN);
  pc_INF_DER:=AgregarPtoControl(TD_INF_DER, TD_INF_DER);
end;
procedure TObjGraf.ReubicElemen;
var pc: TPtoCtrl;
begin
  //ubica puntos de control
  for pc in PtosControl do begin
    case pc.posicion of
    TD_SUP_IZQ:  //superior izquierda, desplaza ancho (por izquierda) fy alto (por arriba)
      pc.Ubicar(fx,fy);
    TD_SUP_CEN:  //superior central, desplaza alto por arriba
      pc.Ubicar(fx+ancho/2,fy);
    TD_SUP_DER:  //superior derecha, desplaza ancho (por derecha) fy alto (por arriba)
      pc.Ubicar(fx+ancho,fy);

    TD_CEN_IZQ:  //central izquierda, desplaza ancho (por izquierda)
      pc.Ubicar(fx,fy+alto/2);
    TD_CEN_DER:  //central derecha, desplaza ancho (por derecha)
      pc.Ubicar(fx+ancho,fy+alto/2);

    TD_INF_IZQ:  //inferior izquierda
      pc.Ubicar(fx,fy+alto);
    TD_INF_CEN:  //inferior central
      pc.Ubicar(fx+ancho/2,fy+alto);
    TD_INF_DER:   //inferior izquierda
      pc.Ubicar(fx+ancho,fy+alto);
    else  //otra ubicación no lo reubica
    end;
  end;
end;
procedure TObjGraf.ReConstGeom;
begin
  ReubicElemen;   //Reubicación de elementos
end;
destructor TObjGraf.Destroy;
begin
  ScrollBars.Free;
  Buttons.Free;        //Libera Buttons fy Lista
  PtosControl.Free;    //Libera Puntos de Control fy lista
  inherited Destroy;
end;
procedure TObjGraf.Ubicar(x0, y0: Single);
//Ubica al objeto en unas coordenadas específicas
begin
  fx := x0;
  fy := y0;
  ReubicElemen;   //reubica sus elementos
end;
function TObjGraf.AddButton(ancho0, alto0: Integer; tipo0: TTipBot;
  EvenBTclk0: TEvenBTclk): TogButton;
//Agrega un botón al objeto.
begin
  Result := TogButton.Create(v2d, tipo0, EvenBTclk0);
  Result.ancho := ancho0;
  Result.alto := alto0;
  Buttons.Add(Result);
end;
function TObjGraf.AddScrollBar(ancho0, alto0: Integer; tipo0: TSBOrientation;
  EvenBTclk0: TEvenBTclk): TogScrollBar;
//Agrega un botón al objeto.
begin
  Result := TogScrollBar.Create(v2d, tipo0, EvenBTclk0);
  Result.ancho := ancho0;
  Result.alto := alto0;
  ScrollBars.Add(Result);
end;
function TObjGraf.AgregarPtoControl(PosicPCtrol, tipDesplaz0: TPosicPCtrol): TPtoCtrl;
//Agrega un punto de control
begin
  Result := TPtoCtrl.Crear(v2d, PosicPCtrol, tipDesplaz0, @ProcPCdim);
  PtosControl.Add(Result);
end;
procedure TObjGraf.ProcPCdim(x0, y0, ancho0, alto0: Single);
//Se usa para atender los requerimientos de los puntos de control cuando quieren
//cambiar el tamaño del objeto.
begin
  //verifica validez de cambio de ancho
  if ancho0 >= ANCHO_MIN then begin
     ancho := ancho0;
     fx := x0;  //solo si cambió el ancho, se permite modificar la posición
//     fil.ancho:= ancho0-6;  //actualiza tabla de campos
  end;
  //verifica validez de cambio de alto
  if alto0 >= ALTO_MIN then begin
     alto := alto0;
     fy := y0; //solo si cambió el alto, se permite modificar la posición
  end;
  ReConstGeom;       //reconstruye la geometría
end;

 //////////////////////////////  TPtoCtrl  //////////////////////////////
procedure TPtoCtrl.SetTipDesplaz(AValue: TPosicPCtrol);
//CAmbiando el tipo de desplazamiento se define el tipo de puntero
begin
  if fTipDesplaz=AValue then Exit;
  fTipDesplaz:=AValue;
  //actualiza tipo de puntero
  case tipDesplaz of
  TD_SUP_IZQ: tipPuntero := crSizeNW;
  TD_SUP_CEN: tipPuntero := crSizeNS;
  TD_SUP_DER: tipPuntero := crSizeNE;

  TD_CEN_IZQ: tipPuntero := crSizeWE;
  TD_CEN_DER: tipPuntero := crSizeWE;

  TD_INF_IZQ: tipPuntero := crSizeNE;
  TD_INF_CEN: tipPuntero := crSizeNS;
  TD_INF_DER: tipPuntero := crSizeNW;
  else        tipPuntero := crDefault ;
  end;
end;
constructor TPtoCtrl.Crear(mGraf: TMotGraf; PosicPCtrol, tipDesplaz0: TPosicPCtrol;
  EvenPCdim0: TEvenPCdim);
begin
  inherited Crear(mGraf, 2*ANC_PCT2, 2*ANC_PCT2);    //crea
  posicion := PosicPCtrol;  //donde aparecerá en el objeto
  tipDesplaz := tipDesplaz0;  //actualiza propiedad
  EvenPCdim := EvenPCdim0;     //Asigna evento para cambiar dimensiones
  visible := true;             //lo hace visible
  fx :=0;
  fy :=0;
end;
procedure TPtoCtrl.Dibujar();
//Dibuja el Punto de control en la posición definida
var xp, yp: Integer;
begin
    if not visible then exit;    //validación
    v2d.XYpant(fx, fy, xp, yp);      //obtiene coordenadas de pantalla
    v2d.Barra0(xp - ANC_PCT2, yp - ANC_PCT2,
               xp + ANC_PCT2, yp + ANC_PCT2, clNavy);  //siempre de tamaño fijo
end;
procedure TPtoCtrl.InicMover(xr, yr: Integer; x0, y0, ancho0, alto0: Single);
//Procedimiento para procesar el evento InicMover del punto de control
begin
    if not visible then exit;    //validación
    inherited InicMover(xr,yr);
    //captura los valores iniciales de las dimensiones
    x1 := x0;
    y1 := y0;
    ancho1 := ancho0;
    alto1 := alto0;
end;
procedure TPtoCtrl.Mover(xr, yr: Integer);
//Realiza el cambio de las variables indicadas de acuerdo al tipo de control y a
//las variaciones indicadas (dx, dy)
var dx, dy: Single;
begin
    if not visible then exit;    //validación
    dx := (xr - Xant) / v2d.Zoom;     //obtiene desplazamiento absoluto
    dy := (yr - Yant) / v2d.Zoom;     //obtiene desplazamiento absoluto
    if EvenPCdim=NIL then exit;    //protección
    case tipDesplaz of
    TD_SUP_IZQ: EvenPCdim(x1+dx, y1+dy, ancho1-dx, alto1-dy);
    TD_SUP_CEN: EvenPCdim(x1, y1+dy, ancho1, alto1-dy);
    TD_SUP_DER: EvenPCdim(x1, y1+dy, ancho1+dx, alto1-dy);

    TD_CEN_IZQ: EvenPCdim(x1+dx, y1, ancho1-dx, alto1);
    TD_CEN_DER: EvenPCdim(x1, y1, ancho1+dx, alto1);

    TD_INF_IZQ: EvenPCdim(x1+dx, y1, ancho1-dx, alto1+dy);
    TD_INF_CEN: EvenPCdim(x1, y1, ancho1, alto1+dy);
    TD_INF_DER: EvenPCdim(x1, y1, ancho1+dx, alto1+dy);
  end;
//  Xant := xr; Yant := yr;   //actualiza coordenadas
end;
procedure TPtoCtrl.MouseUp(Button: TMouseButton; Shift: TShiftState; xp,  yp: Integer);
//Procesa el evento MouseUp del "mouse".
begin
end;
function TPtoCtrl.LoSelec(xp, yp: Integer): boolean;
//Indica si las coordenadas lo selecciona
var xp0, yp0 : Integer; //corodenadas virtuales
begin
    LoSelec := False;
    if not visible then exit;    //validación
    v2d.XYpant(fx, fy, xp0, yp0);   //obtiene sus coordenadas en pantalla
    //compara en coordenadas de pantalla
    If (xp >= xp0 - ANC_PCT2) And (xp <= xp0 + ANC_PCT2) And
       (yp >= yp0 - ANC_PCT2) And (yp <= yp0 + ANC_PCT2) Then
         LoSelec := True;
End;

end.

