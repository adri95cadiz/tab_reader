
%{

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

struct Trastes{
	string afinacion;
	vector <string> notas;
} ;
vector < Trastes > cuerdas;
void reproducir( vector <Trastes> cuerdas, int bpm );
bool activo = false;
unsigned i = 0, bpm = 120;
string command;

%}

afinacion		[EBGDAEC]
inicio			{afinacion}[ ]?[:]?("|")?{vacio}
fin				("|")?[ ]*("\n")
numero			[0-9]
vacio			(("-")|[hpbr/\\vt~()^s])
muted			("x")
traste 			{numero}{1}
traste_2		{numero}{2}

	
%%

{inicio}		{
				activo = true; 
				REJECT;
				}

{afinacion}		{
				if(activo)
				{
					bool iniciado = false;
					while ( !iniciado && i < cuerdas.size() )
					{						
						if( cuerdas[i].afinacion == yytext )
							iniciado = true;
						else 
							i++;
					}
					if( !iniciado )
					{ 	
						Trastes cuerda;
						cuerda.afinacion = yytext[0];					
						cuerdas.push_back( cuerda );						
					}
				}

				}	

{traste}		{
				if(activo)				
					cuerdas[i].notas.push_back(yytext);				
				}

{traste_2}		{
				if(activo)				
					cuerdas[i].notas.push_back(yytext);		
					cuerdas[i].notas.push_back("|");			
				}

{muted}			{
				if(activo)				
					cuerdas[i].notas.push_back("X");				
				}

{vacio}			{
				if(activo)				
					cuerdas[i].notas.push_back("|");				
				}

{fin}			{ 
				activo = false;
				i = 0;
				}

%%
	
int main( int argc, char* argv[] )
{            
	if( argc == 2 || argc == 3 )
	{
		yyin = fopen ( argv[1], "rt" );
		if( yyin == NULL )
		{
			printf ( "El fichero %s no se puede abrir.", argv[1] );
			exit(-1);
		}
	}	
	else yyin = stdin;

	if ( argc == 3 )
		bpm = atoi( argv[2] );

	yylex();
	reproducir( cuerdas, bpm );

	return 0;
}

void reproducir( vector< Trastes > cuerdas, int bpm )
{		
	int ms = 10000000/bpm;
	cout << endl << "Reproduciendo a " << bpm << " bpm." << endl;

	for( unsigned k = 0 ; k < cuerdas.size() ; k++ )	
		cout << cuerdas[k].afinacion << " ";	
	cout << endl;
	
	for( unsigned j = 0 ; j < cuerdas[0].notas.size() ; j++)
	{
		for( unsigned k = 0 ; k < cuerdas.size() ; k++ )
		{
			if( j < cuerdas[k].notas.size() )
			{				
				cout << cuerdas[k].notas[j] << " ";
				if( cuerdas[k].notas[j] != "|")
				{
					command = "canberra-gtk-play -f sounds/"+cuerdas[k].afinacion+cuerdas[k].notas[j]+".wav &";
					system(command.c_str());
				}
			}
		}
		cout << endl;
		usleep(ms);
	}
}
