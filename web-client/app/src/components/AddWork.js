import React, { useRef } from 'react'
import styles from './AddWork.module.css'

export default function AddWork({ addWork }) {
  const inputEl = useRef(null)

  return (
    <div>
      <form className={styles.addWork} onSubmit={e => {
        e.preventDefault()
        if (!inputEl.current.value.trim()) {
          return
        }
        addWork(inputEl.current.value)
        inputEl.current.value = ''
      }}>
        <input className={styles.titleText} placeholder='タイトル' ref={inputEl} />
        <button className={styles.addButton} type='submit'>
          Add Work
        </button>
      </form>
    </div>
  )
}
