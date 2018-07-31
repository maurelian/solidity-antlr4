// Copyright 2016-2017 Federico Bond <federicobond@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

grammar Vyper;
import Python3;

//https://github.com/ethereum/vyper/blob/54b8dc06f258eb0e1815ea222eb5f875aae443f2/vyper/parser/parser.py#L326

// each file is a contract, even an empty file. BUt antlr does not support emptiness very well.
sourceUnit
  : ( contractDefinition ) EOF ;

contractDefinition
  // vyper enforces the order of these sections. Although it's possible in vyper to have any empty file,
  // antlr doesn't support it well. Thus we require at least a functionDefinition
  : customUnitDeclarations *
  interfaceDefinition *
  stateVariableDeclaration *
  eventDefinition *
  storageVarDefinition *
  functionDefinition +
  ;

// Note: somewhere within here, we can put most of the Python3 grammar. Just need to add the restrictions on 
// ordering... or is that really necessary to generate an AST? It's not the end of the world if the 
// AST is valid, but the compiler rejects it. 

/* sourceUnit:interfaceDefinition */
customUnitDeclarations
  : 'unit' ':' '{' 
    customUnitDeclaration 
    (',' customUnitDeclaration) * 
  '}'
  ;

customUnitDeclaration
  : Identifier ':' StringLiteral
  ;

/* sourceUnit:interfaceDefinition */
interfaceDefinition
  : Identifier ;


/* sourceUnit:stateVariableDeclaration */
stateVariableDeclaration
  : stmt;

type
  : '('?  valueType ('(' customUnitName ')')? 
  | referenceType 
  | mappingType ')'?
  ;

// https://vyper.readthedocs.io/en/latest/types.html
valueType
  : 'bool' 
  | 'int128' 
  | 'uint256' 
  | 'decimal' 
  | 'address' 
  | unitType 
  | 'bytes32' 
  | 'bytes[' DecimalNumber ']'
  ;

unitType
  :  (  'timestamp' | 'timedelta' | 'wei_value' | customUnitName )  
  ;

customUnitName
  : Identifier 
  ;

referenceType
  : structType
  | listType
  | tupleType
  ;

structType
  : '{' Identifier ':' valueType (',' Identifier ':' valueType)* '}'
  ;

//  mappingType and mapKey are necessary to remove left recursion. 
// TODO: simplify by combining these two rules
mappingType
  : valueType '[' valueType ']' mapKey*
  | referenceType '[' valueType ']'  mapKey*
  ;

mapKey
  : '[' valueType ']'
  ;


listType
  : valueType '[' IntegerNumber ']'
  ;

tupleType
  : '(' valueType (',' valueType)* ')'
  ;


/* sourceUnit:eventDefinition */
eventDefinition
  : Identifier ':' 'event' eventParameterList
  ;

eventParameterList
  : '(' '{' eventParameter (',' eventParameter)* '}' ')'
  ;

eventParameter
  : Identifier ':' ('indexed(' valueType ')' ) | valueType
  ;

/* sourceUnit:storageVarDefinition */
storageVarDefinition
  : Identifier ;

/* sourceUnit:functionDefinition */
functionDefinition
  : Identifier ;


/* Lexer rules specify token definitions and more or less follow the syntax of parser rules except 
that lexer rules cannot have arguments, return values, or local variables. Lexer rule names must 
begin with an uppercase letter, which distinguishes them from parser rule names 
*/



/* Terminal Tokens */
StringLiteral
  : '"' DoubleQuotedStringCharacter* '"'
  ;

DoubleQuotedStringCharacter
  : ~["\r\n\\] | ('\\' .) ;

Identifier
  : IdentifierStart IdentifierPart* ;

fragment
IdentifierStart
  : [a-zA-Z$_] ;

fragment
IdentifierPart
  : [a-zA-Z0-9$_] ;

IntegerNumber
  : [1-9][0-9]+
  ;

DecimalNumber
  : [0-9]+ ( '.' [0-9]* )? ( [eE] [0-9]+ )? ;

/* Whitespace https://github.com/antlr/antlr4/blob/master/doc/lexer-rules.md */
// A 'skip' command tells the lexer to get another token and throw out the current text.
// channel(Hidden)
// Characters and character constructs that are of no import
// to the parser and are used to make the grammar easier to read
// for humans.
// This will need to be enhanced to handle pythonic indentation blocks.
// good example: https://github.com/antlr/grammars-v4/blob/master/python2/Python2.g4#L376
WS
  : [ \t\r\n]+
    -> skip;


LINE_COMMENT
  : '#' ~[\r\n]* -> channel(HIDDEN) ;