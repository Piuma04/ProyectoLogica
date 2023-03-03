export const numOfRows = 8;
export const numOfColumns = 5;

export function numberToColor(num) {
    switch (num) {
        case 2: return "#249cd1";
        case 4: return "#ec893b";
        case 8: return "#e35b89";
        case 16: return "#af4e7a";
        case 32: return "#a63e4a";
        case 64: return "#8d6ebc";
        default: return "black";
    }
}

export const equalPos = (posA, posB) => posA.toString() === posB.toString();

export const valueInPos = (pos, grid) => {
    return grid[pos[0] * numOfColumns + pos[1]];
}

export const posInPath = (pos, path) => {
    return path.some(posI => equalPos(posI, pos));
}

export const connectionInPath = (posA, posB, path) => {
    return path.some((pos, i) => equalPos(pos, posA) && i + 1 < path.length && equalPos(path[i + 1], posB));
}

export const isAdyacent = (posA, posB) => {
    return !equalPos(posA, posB) && Math.abs(posA[0] - posB[0]) <= 1 && Math.abs(posA[1] - posB[1]) <= 1;
}