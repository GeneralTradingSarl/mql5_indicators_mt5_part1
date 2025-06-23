//+----------------------------------------------------------------------+
//|                                                         BPNN_MQL.mq5 |
//|                             Copyright (c) 2009-2019, gpwr, Marketeer |
//|                              https://www.mql5.com/en/users/marketeer |
//|                              https://www.mql5.com/en/users/gpwr      |
//| Based on original idea and source codes of gpwr                      |
//|                                                       rev.18.12.2019 |
//+----------------------------------------------------------------------+
#property library

// this let it know to the included BPNN_MQL.mqh that we don't need the import,
// because the source is embedded directly (inline);
// unfortunately, MQL does not provide a predefined built in macro for program
// type (library, indicator, etc), so the 'library' flag is duplicated in defines
#define BPNN_LIBRARY

#include <BPNN_MQL.mqh>

// this is the actual source code of the library; optionally, it can be included
// in any program as is, without the need to import the ex5-library
#include <BPNN_MQL_IMPL.mqh>