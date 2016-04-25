int xorshift(unsigned int change_seed)
{
    int random;
    static unsigned int seed = 2463534242;

    if (change_seed) { // change_seed != 0なら種をかえる
       seed = change_seed;
    }
    
    seed = (seed << 13) ^ seed;
    seed = (seed >> 17) ^ seed;
    seed = (seed << 5) ^ seed;

    random = (int)seed;

    return random;
}
