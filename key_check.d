immutable int KEY_LENGTH = 40;

class ConversionException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

int wrong(){
    import std.stdio: writeln;

    writeln("invalid key");
    return 1;
}

bool check_first(string piece){
    import std.conv;

    immutable string[] BANNED = ["123", "456", "789"];

    if (piece.length != 3)
        return false;
    
    try{
        to!int(piece);
    } catch(ConvException){
        return false;
    }

    if (piece[0] == piece[1] || piece[1] == piece[2] || piece[0] == piece[2] || piece[0] == '0')
        return false;

    foreach (string banned; BANNED){
        if (banned == piece){
            return false;
        }
    }

    return true;
}

bool check_second(string piece){
    import std.conv;

    if (piece.length != 7)
        return false;    

    int sum = 0;
    bool[char] repeat;
    foreach (char digit; piece)
    {
        try{
            sum += to!int(digit);
            repeat[digit] = true;
        } catch(ConvException){
            return false;
        }
    }
    if (sum % 7 != 0 || repeat.length <=5)
        return false;

    return true;
}

bool check_vendor(string vendor){
    if (vendor.length != 3){
        return false;
    }
    string[3] allowed = ["ptm", "ctf", "plt"];

    foreach (string all; allowed)
    {
        if (vendor == all)
            return true;
    }

    return false;
}

string base24ToHex(string number){

    import std.conv;
    import std.digest.digest;
    import std.array;

    int[char] BASE = ['B':0, 'C':1, 'D':2, 'F':3, 'G':4, 'H':5, 'J':6,'K':7,'M':8, 'P':9, 'Q':10, 'R':11, 'T':12, 'V':13, 'W':14, 'X':15, 'Y':16, '2':17, '3':18, '4':19, '6':20, '7':21, '8':22, '9':23];
    string HEX = "0123456789ABCDEF";

    int l = to!int(number.length);
    int[] fs = new int[l];
    int k = 0;

    for (int i = l -1; i >= 0; i--){
        char digit = to!char(number[i]);
        auto p = digit in BASE;
        if (p is null)
            throw new ConversionException("invalid char");
        fs[k++] = BASE[digit];
    }

    int ol = l * (24 / 16+1);
        int[] ts = new int[ol+10]; //assign accumulation array
        int[] cums = new int[ol+10]; //assign the result array
        ts[0] = 1; //initialize array with number 1 
        
        //evaluate the output
        for (int i = 0; i < l; i++) //for each input digit
        {
            for (int j = 0; j < ol; j++) //add the input digit 
				// times (base:to from^i) to the output cumulator
            {
                cums[j] += ts[j] * fs[i];
                int temp = cums[j];
                int rem = 0;
                int ip = j;
                do // fix up any remainders in base:to
                {
                    rem = temp / 16;
                    cums[ip] = temp-rem*16; ip++;
                    cums[ip] += rem;
                    temp = cums[ip];
                }
                while (temp >=16);
            }
            
            //calculate the next power from^i) in base:to format
            for (int j = 0; j < ol; j++)
            {
                ts[j] = ts[j] * 24;
            } 
            for(int j=0;j<ol;j++) //check for any remainders
            {
                int temp = ts[j];
                int rem = 0;
                int ip = j;
                do  //fix up any remainders
                {
                    rem = temp / 16;
                    ts[ip] = temp - rem * 16; ip++;
                    ts[ip] += rem;
                    temp = ts[ip];
                }
                while (temp >= 16);
            }
        }

    bool first = false;
    auto strBuilder = appender!string;
    for(int i = ol; i >= 0; i--){
        if (cums[i] != 0)
            first = true;
        if (!first)
            continue;
        strBuilder.put(HEX[cums[i]]);
    }

    return strBuilder.data;

}

ubyte[10] reduce(ubyte[20] to_reduce){
    import std.conv;    

    ubyte[10] reduced;
    for(int i = 0; i < 20; i += 2){
        reduced[i/2] = to!ubyte((to!int(to_reduce[i]) & 0x000000f0) + (to!int(to_reduce[i+1]) & 0x0000000f));
    }
    return reduced;
}

bool check_signature(string num, string signature){
    import std.digest.sha : toHexString, sha1Of;

    ubyte[10] secret = [80, 87, 78, 84, 72, 69, 77, 65, 76, 76];
    ubyte[10] computed;

    ubyte[20] hash = sha1Of(num);
    ubyte[10] reduced = reduce(hash);

    for (int i = 0; i < 10; i++){
        computed[i] = reduced[i] ^ secret[i];
    }

    return signature == toHexString(computed);
}

int main(){
    import std.stdio;
    import std.string;
    import std.process;

    writeln("Gimme key:");
    string key = strip(stdin.readln());
    //Check length
    if (key.length != KEY_LENGTH){        
        return wrong();
    }

    //check dashes
    auto pieces = split(key, "-");
    if (pieces.length != 5){
        return wrong();
    }

    //check first
    if (!check_first(pieces[0]))
        return wrong();

    //check second
    if (!check_second(pieces[1]))
        return wrong();

    // check third
    if (!check_vendor(pieces[2]))
        return wrong();

    //check fourth
    if (pieces[3].length != 5)
        return(wrong());
    string num;
    try{
        num = base24ToHex(pieces[3]);
    } catch(ConversionException) {
        return wrong();
    }

    //check signature
    if (pieces[4].length != 18)
        return wrong();
    string signature = base24ToHex(pieces[4]);
    if (!check_signature(num, signature))
        return wrong();

    //win
    writeln("Product correctly activated");
    writeln(environment.get("FLAG", "ptm{redacted}"));

    return 0;
}