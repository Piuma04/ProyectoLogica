function Clue({ clue ,highlight}) {
    const name = highlight===1?"discoveredClue":"clue";
    return (
        <div className={name}>
            {clue.map((num, i) =>
                <div key={i}>
                    {num}
                </div>
            )}
        </div>
    );
}
export default Clue;