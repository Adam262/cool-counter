(function() {
  const updateCountView = (count) => {
    const countElement = document.querySelector("#count");

    countElement.innerHTML = `<span> ${count} </span>`;
  }

  const updateCountServer = (action) => {
    const data = { action };

    fetch('/update', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    }).
    then((response) => response.json()).
    then((data) => {
      updateCountView(data.count);
    }).
    catch((error) => {
      console.error('Error:', error);
    });
  }

  const plusButton = document.querySelector("#plus-button");
  plusButton.addEventListener('click', () => updateCountServer('plus'));

  const minusButton = document.querySelector("#minus-button");
  minusButton.addEventListener('click', () => updateCountServer('minus'));

  const resetButton = document.querySelector("#reset-button");
  resetButton.addEventListener('click', () => updateCountServer('reset'));
}());  
