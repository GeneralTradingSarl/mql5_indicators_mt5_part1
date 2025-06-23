//+------------------------------------------------------------------+
//|                                        ChartObjectsCopyPaste.mq5 |
//|                                        Copyright 2024, Marketeer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Marketeer"
#property link      "https://www.mql5.com/en/users/marketeer"
#property version   "1.0"
#property description "Copy && paste selected graphical objects between charts via Windows clipboard as text.\n\nUse Ctrl+Q on a source chart, then Ctrl+J on a target chart.\n"
#property description "Based on ObjectGroupEdit.mq5 from the algotrading book: https://www.mql5.com/en/book/applications/objects/objects_properties_get_set"

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

#include <MQL5Book/ObjectMonitorExt.mqh>

// !!! UNCOMMENT THIS #define BEFORE COMPILATION
//     (this is aguard to pass automatic check-up of the Codebase)
// #define DLL_LINK

#define PUSH(A,V) (A[ArrayResize(A, ArraySize(A) + 1) - 1] = V)


input bool MakeAllSelectable = false;
input bool LogDetails = false;


class ObjectMonitorClipboard: public ObjectMonitor
{
public:
   ObjectMonitorClipboard(const string objid, const int &flags[]): ObjectMonitor(objid, flags)
   {
   }
   
   string serialize() const
   {
      const long type = ((ObjectMonitorInterface *)&this).get(OBJPROP_TYPE);
      const string name = ((ObjectMonitorInterface *)&this).name();
      
      const string data = EnumToString((ENUM_OBJECT)type) + "\t" + name + "\t" + (string)type + "\t" + (string)ObjectFind(0, name) +
         ((ObjectMonitorBase<long,ENUM_OBJECT_PROPERTY_INTEGER> *)(m[0][])).serialize() +
         ((ObjectMonitorBase<double,ENUM_OBJECT_PROPERTY_DOUBLE> *)(m[1][])).serialize() +
         ((ObjectMonitorBase<string,ENUM_OBJECT_PROPERTY_STRING> *)(m[2][])).serialize();
      return data;
   }
   
   void deserialize(const string &lines[], const int start, const int stop)
   {
      string type2name[];
      for(int j = start; j < stop; j++)
      {
        if(StringSplit(lines[j], '\t', type2name) < 1) continue; // skip empty lines
        
        if(type2name[0] == "enum ENUM_OBJECT_PROPERTY_INTEGER")
        {
          j += ((ObjectMonitorBase<long,ENUM_OBJECT_PROPERTY_INTEGER> *)(m[0][])).deserialize(lines, j + 1, stop);
        }
        else if(type2name[0] == "enum ENUM_OBJECT_PROPERTY_DOUBLE")
        {
          j += ((ObjectMonitorBase<double,ENUM_OBJECT_PROPERTY_DOUBLE> *)(m[1][])).deserialize(lines, j + 1, stop);
        }
        else if(type2name[0] == "enum ENUM_OBJECT_PROPERTY_STRING")
        {
          j += ((ObjectMonitorBase<string,ENUM_OBJECT_PROPERTY_STRING> *)(m[2][])).deserialize(lines, j + 1, stop);
        }
      }
   }
   
};

int consts[2048];
string selected[];
ObjectMonitorClipboard *objects[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   for(int i = 0; i < ArraySize(consts); ++i)
   {
      consts[i] = i;
   }
   
   EventSetTimer(1);
}

//+------------------------------------------------------------------+
//| Monitor properties of objects selected on the chart              |
//+------------------------------------------------------------------+
void TrackSelectedObjects()
{
   for(int j = 0; j < ArraySize(objects); ++j)
   {
      delete objects[j];
   }
   
   ArrayResize(objects, 0, ArraySize(selected));

   for(int i = 0; i < ArraySize(selected); ++i)
   {
      PUSH(objects, new ObjectMonitorClipboard(selected[i], consts));
   }
}

//+------------------------------------------------------------------+
//| Timer event handler                                              |
//+------------------------------------------------------------------+
void OnTimer()
{
   // collect names of selected objects in the following array
   string updates[];
   const int n = ObjectsTotal(0);
   for(int i = 0; i < n; ++i)
   {
      const string name = ObjectName(0, i);
      
      if(MakeAllSelectable && !ObjectGetInteger(0, name, OBJPROP_SELECTABLE))
      {
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
      }
      
      if(ObjectGetInteger(0, name, OBJPROP_SELECTED))
      {
         PUSH(updates, name);
      }
   }
   
   if(ArraySize(selected) != ArraySize(updates))
   {
      ArraySwap(selected, updates);
      Comment("Selected objects: ", ArraySize(selected));
      TrackSelectedObjects();
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//| (dummy here, required for indicator)                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   return rates_total;
}

//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_KEYDOWN)
   {
      const ulong c = (ulong)TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL);
      // PrintFormat("%X %X", c, lparam); // Q 0x51, J 0x4A
      if(c > 1)
      {
        if(lparam == 'Q')
        {
          string content;
          for(int i = 0; i < ArraySize(selected); ++i)
          {
             Print("Copy " + objects[i].name());
             content += objects[i].serialize() + "\n";
          }
          if(LogDetails) Print("Writing to clipboard...\n", content);
          WriteClipboard(content);
          Comment(StringFormat("%d objects sent to clipboard", ArraySize(selected)));
        }
        else if(lparam == 'J')
        {
          const string text = ReadClipboard();
          if(LogDetails) Print("Pasted from clipboard: \n" + text);
          const int n = ParseClipboardObjects(text);
          Comment(StringFormat("%d objects received from clipboard", n));
        }
      }
   }
}

//+------------------------------------------------------------------+
//| Finalization handler                                             |
//+------------------------------------------------------------------+
void OnDeinit(const int)
{
   for(int j = 0; j < ArraySize(objects); ++j)
   {
      delete objects[j];
   }
   Comment("");
}

//+------------------------------------------------------------------+
//| Read clipboard text and convert it to chart objects              |
//+------------------------------------------------------------------+
int ParseClipboardObjects(const string text)
{
   string lines[];
   int objs[];
   
   const int n = StringSplit(text, '\n', lines);
   for(int i = 0; i < n; i++)
   {
     StringTrimRight(lines[i]); // remove trailing '\r'
     if(StringFind(lines[i], "OBJ_") == 0)
     {
       PUSH(objs, i);
     }
   }
   
   const int m = ArraySize(objs);
   
   for(int i = 0; i < m; i++)
   {
     string type2name[];
     if(StringSplit(lines[objs[i]], '\t', type2name) == 4)
     {
        if(ObjectFind(0, type2name[1]) >= 0)
        {
           PrintFormat("Object '%s' already exists, skipping", type2name[1]);
           continue;
        }
        Print("Paste ", type2name[1]);
        ObjectCreate(0, type2name[1], (ENUM_OBJECT)type2name[2], (int)type2name[3] /* !subwindow is not adjustable in MQL5! */, 0, 0);
        ObjectMonitorClipboard temp(type2name[1], consts);
        temp.deserialize(lines, objs[i] + 1, i < m - 1 ? objs[i + 1] : n);
     }
   }
   ChartRedraw();
   return m;
}

//+------------------------------------------------------------------+

#ifdef DLL_LINK
//+------------------------------------------------------------------+
//| DLL-related permissions are required!                            |
//| Clipboard reading is the task implemented by DLLs.               |
//+------------------------------------------------------------------+
#include <WinApi/winuser.mqh>
#include <WinApi/winbase.mqh>

//+------------------------------------------------------------------+
//| We need thess defines and import for accessing Windows clipboard |
//+------------------------------------------------------------------+
#define CF_UNICODETEXT 13 // one of standard clipboard formats
#define GMEM_MOVEABLE 0x0002
#define GMEM_ZEROINIT 0x0040

#import "kernel32.dll"
string lstrcatW(PVOID string1, const string string2);
#import

//+------------------------------------------------------------------+
//| Example function to use DLL for reading Windows clipboard        |
//+------------------------------------------------------------------+
string ReadClipboard()
{
   string text;
   if(OpenClipboard(NULL))
   {
      HANDLE h = GetClipboardData(CF_UNICODETEXT);
      PVOID p = GlobalLock(h);
      if(p != 0)
      {
         text = lstrcatW(p, "");
         GlobalUnlock(h);
      }
      CloseClipboard();
   }
   return text;
}

//+------------------------------------------------------------------+
//| Example function to use DLL for writing Windows clipboard        |
//+------------------------------------------------------------------+
void WriteClipboard(const string text)
{
   if(OpenClipboard(NULL))
   {
      EmptyClipboard();

      HANDLE h = GlobalAlloc(GMEM_MOVEABLE | GMEM_ZEROINIT, (StringLen(text) + 1) * 2);
      
      PVOID p = GlobalLock(h);
      if(p != 0)
      {
         /**/lstrcatW(p, text);
         SetClipboardData(CF_UNICODETEXT, h);
         GlobalUnlock(h);
      }
      CloseClipboard();
   }
}

#else

string ReadClipboard()
{
  Alert("ReadClipboard stub: Please uncomment #define DLL_LINK and recompile");
  return "";
}

void WriteClipboard(const string text)
{
  Alert("WriteClipboard stub: Please uncomment #define DLL_LINK and recompile");
}

#endif
//+------------------------------------------------------------------+
