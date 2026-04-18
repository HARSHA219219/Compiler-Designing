int limit = 4;

int main() {
    total = 0;

    for (i = 0; i < limit; i = i + 1)
        if (i != 2)
            total = total + i;
        else
            total = total - 1;

    return total;
}
